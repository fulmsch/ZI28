#code ROM

u_mount:
;; Mount filesystem.
;;
;; Input:
;; : (de) - source
;; : (hl) - dest (max. 32 bytes incl. terminator)
;; : a - filesystem type (+mountflags?)
;;
;; Output:
;; : a - errno

	push hl ;dest
	push af ;a = fs type

	call k_open ;open source
	;e = fd, a = errno
	pop bc ;b = fs type
	pop hl ;dest
	cp 0
	ret nz
	ld d, b ;fs type
k_mount:
;; Mount a drive file
;;
;; Creates a new entry in the drive table
;; and initialises the filesystem
;;
;; Input:
;; : d - filesystem type
;; : e - device fd
;; : (hl) - dest (max. 32 bytes incl. terminator)
;;
;; Output:
;; : a - errno
; Errors: 0=no error
;         2=invalid drive number

#local
	;find free drive entry
	;get parent and path of dest
	;store path in drive entry
	;store fd in drive entry
	;find fs driver, store in drive entry
	;if parent->child == 0xff link parent->child
	;else follow sibling list and link last sibling

	push hl ;dest

	ld hl, driveTablePaths
	ld bc, driveTableEntrySize
	xor a
tableSearchLoop:
	cp (hl)
	jr z, tableEntryFound
	add hl, bc
	jr nc, tableSearchLoop ;no entry found

	pop hl
	ld a, 1 ;no free spot found
	ret

tableEntryFound:
	;hl = path table entry
	;de = fs type / devfd
	ex (sp), hl
	;hl = dest
	push de ;type/fd

	call get_drive_and_path
	jr c, pathError
	;hl = rel path
	;e = parent drive
	ld a, e
	pop bc ;type/fd
	pop de ;path entry

	push bc ;type/fd
	ld b, a ;parent drive
	ld c, e ;new drive
	push bc

	;copy hl to de
	ld b, fileTableEntrySize
	call strncpy
	cp 0
	jr nz, pathError ;dest too long TODO clean up drive entry
	;de points to null terminator of string copy
	dec de
	ld a, (de)
	cp '/'
	jr z, destTerminated
	;try to append a '/'
	inc e
	ld a, 0x1f
	and e
	xor 0x1f
	jr z, pathError
	ld a, '/'
	ld (de), a
	inc e
	xor a
	ld (de), a

destTerminated:
	pop bc ;parent/new drive
	pop de ;type/fd

	ld a, 0xff
	;ld ixh, 0 + (driveTable >> 8)
	DEFB 0xdd, 0x26, 0 + (driveTable >> 8)
	;ld ixl, c
	DEFB 0xdd, 0x69
	ld (ix + driveTableChild), a ;child
	ld (ix + driveTableSibling), a ;sibling
	ld (ix + driveTableDevfd), e ;devfd

	;link new table entry
	;b = parent, c = new drive
	ld h, 0 + (driveTable >> 8)
	ld l, b
	ld a, (hl)
	cp 0xff
	jr z, appendEnd

appendToSiblingList:
	ld l, a ;hl = first child of parent
appendLoop:
	inc l
	ld a, (hl)
	cp 0xff
	jr z, appendEnd
	ld l, a
	jr appendLoop

appendEnd:
	ld (hl), c

	jp storeAndCallFsInit


invalidFsDriver:
	ld a, 1 ;invalid driver
	ret

pathError:
	pop hl
	pop hl
	ld a, 1 ;path error
	ret
#endlocal
