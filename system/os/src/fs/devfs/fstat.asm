SECTION rom_code
INCLUDE "os.h"
INCLUDE "devfs.h"

PUBLIC devfs_fstat

EXTERN devfs_statFromEntry

devfs_fstat:
;; Get information about a file.
;;
;; Input:
;; : ix - file entry addr
;; : (de) - stat
;;
;; Output:
;; : a - errno


	;check if root dir
	ld a, (ix + dev_fileTableDirEntry)
	cp 0x00
	jr nz, notRootDir
	ld a, (ix + dev_fileTableDirEntry + 1)
	cp 0x00
	jr z, rootDir

notRootDir:
	ld b, ixh
	ld c, ixl
	ld hl, dev_fileTableDirEntry
	add hl, bc
	;hl points to dirEntry
	jp devfs_statFromEntry

rootDir:
	xor a
	ld (de), a ;name = null
	ld hl, STAT_ATTRIB
	add hl, de
	;TODO permission of drive
	ld (hl), SP_READ | SP_WRITE | ST_DIR
	;file size is unspecified
	;a = 0
	ret
