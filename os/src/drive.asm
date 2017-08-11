;; Contains routines for accessing drives
.list
;*********** Drive Table ********************
;.define driveTableEntrySize  32
;.define driveTableEntries    9

;driveTable:
;	.db 1
;	.db 0
;	.dw fat_fsDriver
;	.resb 28

;	.resb driveTableEntrySize * driveTableEntries

.define driveTableLabel    0                          ;5 bytes
.define driveTableDevfd    driveTableLabel + 5       ;1 byte
.define driveTableFsdriver driveTableDevfd + 1        ;2 bytes
                                                      ;-------
                                                ;Total 8 bytes
.define driveTableFsdata   driveTableFsdriver + 2 ;Max 24 bytes

.define fs_init     0
.define fs_open     2
.define fs_close    4 ;not used yet
.define fs_readdir  6

.func getDriveAddr:
;; Finds the drive entry of a given drive number
;;
;; Input:
;; : a - drive number
;;
;; Output:
;; : hl - table entry address
;; : carry - out of bounds
;; : nc - no error
;;
;; See also:
;; : [getTableAddr](#getTableAddr)

	ld hl, driveTable
	ld de, driveTableEntrySize
	ld b, driveTableEntries
	jp getTableAddr
.endf ;getDriverAddr


u_mount:
	add a, fdTableEntries

.func k_mount:
;; Mount a drive file
;;
;; Creates a new entry in the drive table
;; and initialises the filesystem
;;
;; Input:
;; : de - fs driver
;; : (hl) - drive label (max. 5 bytes)
;; : a - devfd
;old : h-devfd, a-drivenr
;;
;; Output:
;; : a - errno
; Errors: 0=no error
;         2=invalid drive number

	push de ;driver
	push hl ;label
	push af ;devfd

	ld ix, driveTable
	ld b, driveTableEntries
	ld de, driveTableEntrySize

tableSearchLoop:
	ld a, (ix + 0)
	cp 0x00
	jr z, tableSpotFound
	add ix, de
	djnz tableSearchLoop
	;no free spot found, return error
	pop hl
	pop hl
	pop hl
	ld a, 0xf5
	ret


tableSpotFound:
	;ix points to valid drive entry
	pop af ;devfd
	ld (ix + driveTableDevfd), a

	;copy the drive label
	;TODO maybe add a null terminator if strlen = max strlen
	ld b, 5
	pop hl ;drive label
	ld d, ixh
	ld e, ixl
	call strncpy

	pop de ;driver
	ld (ix + driveTableFsdriver), e
	ld (ix + driveTableFsdriver + 1), d

	ld hl, fs_init
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl

	jp (hl)


invalidDrive:
	pop de
	pop hl
	ld a, 2
	ret
.endf ;k_mount


k_umount:


u_chmain:
.func k_chmain:
;; Change the main drive.
;;
;; The main drive can be accessed with a path starting with ":/".
;; The OS will search system files on this drive.
;;
;; Input:
;; : (de) - drive name
;;
;; Output:
;; : a - errno

	;TODO ensure that there cannot be any issues with strings that are too long

	ex de, hl
	ld de, k_chmain_pathBuffer
	ld b, 5
	;TODO maybe add a null terminator if strlen = max strlen
	call strncpy
	ld a, '/'
	ld (de), a

	ld hl, k_chmain_pathColon
	ld (hl), ':'
	;convert label to uppercase
	call strtup

	;try to open the drive
	ld de, k_chmain_pathColon
	ld a, O_RDONLY
	call k_open
	push af
	ld a, e
	call k_close
	pop af

	cp 0
	jr nz, invalidDrive ;TODO make this work

	;copy the drive label
	ld b, 6
	ld hl, k_chmain_pathColon
	ld de, env_mainDrive
	jp strncpy

invalidDrive:
	ld a, 1
	ret
.endf


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
