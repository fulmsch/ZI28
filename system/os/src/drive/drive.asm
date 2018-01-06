SECTION rom_code
;; Contains routines for accessing drives

INCLUDE "os.h"
INCLUDE "string.h"
INCLUDE "drive.h"
INCLUDE "vfs.h"

EXTERN k_open
EXTERN get_drive_and_path


PUBLIC addFsDriver
addFsDriver:
;TODO implement


;TODO move to ram
;.align_bytes 16
EXTERN devfs_fsDriver
EXTERN fat_fsDriver
fsDriverTable:
	DEFW devfs_fsDriver
	DEFW fat_fsDriver
	DEFW 0x0000
	DEFW 0x0000
	DEFW 0x0000
	DEFW 0x0000
	DEFW 0x0000
	DEFW 0x0000


PUBLIC getTableAddr
getTableAddr:
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

	cp 0x00
	ret z
	cp b
	jr nc, getTableAddr_invalid
getTableAddr_loop:
	add hl, de
	dec a
	jr nz, getTableAddr_loop
	;this should return c (error) if the loop wraps around (unconfirmed)
	ret

getTableAddr_invalid:
	scf
	ret


SECTION ram_driveTable
PUBLIC driveTable, driveTablePaths
driveTable:
	defs driveTableEntries * driveTableEntrySize
driveTablePaths:
	defs driveTableEntries * driveTableEntrySize
