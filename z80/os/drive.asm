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

.define fs_init  0
.define fs_open  2
.define fs_close 4

.func getDriveAddr:
;Inputs: a = index
;Outputs: hl = table entry address
;Errors: c = out of bounds
;        nc = no error

	ld hl, driveTable
	ld de, driveTableEntrySize
	ld b, driveTableEntries
	jp getTableAddr
.endf ;getDriverAddr


.func k_mount:
;; Description: Create a new entry in the drive table
;;              and initialise the filesystem
;; Inputs: de = fs driver, h = devfd, a = drive number
;; Outputs: a = errno
;; Errors: 0=no error
;;         2=invalid drive number

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
;Inputs: hl = table start, de = entry size, b = max entries, a = index
;Outputs: hl = table entry address
;Errors: c = out of bounds
;        nc = no error

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
