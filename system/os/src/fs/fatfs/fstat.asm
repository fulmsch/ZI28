MODULE fatfs_fstat

SECTION rom_code
INCLUDE "os.h"
INCLUDE "fatfs.h"
INCLUDE "vfs.h"

PUBLIC fat_fstat

EXTERN k_read, k_lseek, fat_statFromEntry

fat_fstat:
;; Get information about a file.
;;
;; Input:
;; : ix - file entry addr
;; : (de) - stat
;;
;; Output:
;; : a - errno


	push de

	;check if root dir (filetype == dir && startCluster == 0)
	ld a, (ix + fileTableMode)
	bit M_DIR_BIT, a
	jp z, notRootDir

	ld l, (ix + fat_fileTableStartCluster)
	ld h, (ix + fat_fileTableStartCluster + 1)
	ld de, 0
	or a
	sbc hl, de
	jr z, rootDir
notRootDir:
	ld a, (ix + fileTableDriveNumber)
	ld h, 0 + (driveTable >> 8)
	ld l, a
	;hl = drive entry

	ld bc, driveTableDevfd
	add hl, bc
	ld a, (hl) ;a = devfd

	ld d, ixh
	ld e, ixl
	ld hl, fat_fileTableDirEntryAddr
	add hl, de
	ex de, hl ;(de) = dir entry addr

	ld h, SEEK_SET
	push af
	call k_lseek
	pop af
	;TODO error handling
	
	;load the directory entry
	ld de, fat_dirEntryBuffer
	ld hl, 32
	call k_read
	;TODO error handling
	pop de
	jp fat_statFromEntry

rootDir:
	pop de
	xor a
	ld (de), a ;name = null
	ld hl, STAT_ATTRIB
	add hl, de ;(hl) = stat attrib
	;TODO permission of drive
	ld (hl), ST_DIR | SP_WRITE | SP_READ
	;a = 0
	ret

error:
	pop de
	ld a, 1
	ret
