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

.define driveTableStatus   0
.define driveTableDevfd    driveTableStatus + 1
.define driveTableFsdriver driveTableDevfd + 1
.define driveTableFsdata   driveTableFsdriver + 2

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


.func k_mount:
;; Mount a drive file
;;
;; Creates a new entry in the drive table
;; and initialises the filesystem
;;
;; Input:
;; : de - fs driver
;; : h - devfd
;; : a - drive number
;;
;; Output:
;; : a - errno
; Errors: 0=no error
;         2=invalid drive number

	push de
	push hl
	call getDriveAddr
	jr c, invalidDrive
	ld a, (hl)
	cp 0
	jr nz, invalidDrive
	push hl
	pop ix
	;ix points to valid drive entry
	pop hl
	pop de
	ld (ix + driveTableDevfd), h
	ld (ix + driveTableFsdriver), e
	ld (ix + driveTableFsdriver + 1), d

	ld hl, fs_init
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl

	ld de, return
	push de
	jp (hl)

return:
	ld a, 1
	ld (ix + 0), a
	ret


invalidDrive:
	pop de
	pop hl
	ld a, 2
	ret
.endf ;k_mount


k_umount:



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
