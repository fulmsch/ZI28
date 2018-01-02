SECTION rom_code
INCLUDE "os.h"
INCLUDE "fatfs.h"
INCLUDE "math.h"
INCLUDE "os_memmap.h"

PUBLIC fat_statFromEntry

EXTERN fat_buildFilename

fat_statFromEntry:
;; Creates a stat from a directory entry.
;;
;; Input:
;; : (de) - stat
	
	ld hl, fat_dirEntryBuffer
	;(de) = stat
	push de
	call fat_buildFilename
	pop de

	ld hl, fat_dirEntryBuffer + 0x0b ;attributes
	ld b, (hl)
	ld hl, STAT_ATTRIB
	add hl, de ;(hl) = stat attrib

	ld a, SP_READ
	bit FAT_ATTRIB_RDONLY, b
	jr nz, skipWrite
	or SP_WRITE
skipWrite:
	bit FAT_ATTRIB_DIR, b
	jr nz, dir
	or ST_REG
	jr writeAttrib
dir:
	or ST_DIR
writeAttrib:
	ld (hl), a

	ld bc, STAT_SIZE - (STAT_ATTRIB)
	add hl, bc
	ex de, hl ;(de) = stat size
	ld hl, fat_dirEntryBuffer + 0x1c ;size
	call ld32
	xor a
	ret
