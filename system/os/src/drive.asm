;; Contains routines for accessing drives
.list
;*********** Drive Table ********************

.define driveTableChild    0                          ;1 byte
.define driveTableSibling  driveTableChild + 1        ;1 byte
.define driveTableDevfd    driveTableSibling + 1      ;1 byte
.define driveTableFsdriver driveTableDevfd + 1        ;2 bytes
                                                      ;-------
                                                ;Total 5 bytes
.define driveTableFsData   driveTableFsdriver + 2 ;Max 27 bytes

.define fs_init     0
.define fs_open     2
.define fs_close    4 ;not used yet
.define fs_readdir  6
.define fs_fstat    8
.define fs_unlink  10


.func addFsDriver:
;TODO implement
.endf

;TODO move to ram
.align_bytes 16
fsDriverTable:
	.dw devfs_fsDriver
	.dw fat_fsDriver
	.dw 0x0000
	.dw 0x0000
	.dw 0x0000
	.dw 0x0000
	.dw 0x0000
	.dw 0x0000

.func dummyRoot:
;; Create the root node of the filesystem.
	ld hl, driveTablePaths
	ld (hl), '/'
	inc l
	ld (hl), 0x00
	dec l
	dec h
	ld (hl), 0xff
	inc l
	ld (hl), 0xff
	inc l
	ld (hl), 0xff
	inc l
	ld (hl), 0x00
	inc l
	ld (hl), 0x00
	ret
.endf

.func mountRoot:
;; Populate the root node of the filesystem.
;;
;; Input:
;; : de - device name
;; : a - fs type

	push af
	ld a, O_RDWR
	call k_open
	pop hl ;h = fs type
	cp 0
	ret nz
	ld a, e ;fd
	ld d, h ;fs type
	ld ix, driveTable
	ld (ix + driveTableDevfd), a
	jp storeAndCallFsInit
.endf

.func u_mount:
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
.endf
.func k_mount:
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
	.db 0xdd, 0x26, 0 + (driveTable >> 8)
	;ld ixl, c
	.db 0xdd, 0x69
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
.endf ;k_mount


.func storeAndCallFsInit:
;; Store and call the fs init routine
;;
;; Input:
;; : d - fs type
;; : ix - drive entry

	ld a, 0x07
	and d
	add a, a ;a = offset in fs driver table
	ld de, fsDriverTable
	add a, e
	ld e, a ;(de) = fsDriver
	ex de, hl ;(hl) = fsDriver

	ld e, (hl)
	inc hl
	ld d, (hl)
	;de = fsDriver

	and a ;clear carry
	ld hl, 0
	adc hl, de
	jr z, error ;fsdriver null pointer
	ld (ix + driveTableFsdriver), e
	ld (ix + driveTableFsdriver + 1), d

	ld hl, fs_init
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl

	jp (hl)


error:
	ld a, 1 ;invalid fs type
	ret
.endf


u_unmount:
k_unmount:
	ret


.func getTableAddr:
;; Finds the file entry of a given fd
;;
;; Input:
;; : hl - table start address
;; : de - entry size
;; : b - maximum number of entries
;; : a - index
;;
;; Output:
;; : hl - table entry address
;; : carry - out of bounds
;; : nc - no error

	cp 00h
	ret z
	cp b
	jr nc, invalid
loop:
	add hl, de
	dec a
	jr nz, loop
	;this should return c (error) if the loop wraps around (unconfirmed)
	ret

invalid:
	scf
	ret
.endf
