.list
;*********** Drive Table ********************
.define driveTableEntrySize  32
.define driveTableEntries    9

driveTable:
	.db 1
	.db 0
	.dw fat_fsDriver
	.resb 28

	.resb driveTableEntrySize * driveTableEntries

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

k_mount:
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
