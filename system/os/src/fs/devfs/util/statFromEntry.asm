MODULE devfs_statFromEntry

SECTION rom_code
INCLUDE "os.h"
INCLUDE "string.h"

PUBLIC devfs_statFromEntry

devfs_statFromEntry:
;; Creates a stat from a directory entry.
;;
;; Input:
;; : (hl) - dir entry
;; : (de) - stat

	;copy name
	push de
	call strcpy
	pop de
	ex de, hl
	;(hl) = stat, (de) = dirEntry
	ld bc, STAT_ATTRIB
	add hl, bc
	;(hl) = stat_attrib
	;TODO store actual attribs
	ld (hl), SP_READ | SP_WRITE | ST_CHAR

	;file size is unspecified

	xor a
	ret
