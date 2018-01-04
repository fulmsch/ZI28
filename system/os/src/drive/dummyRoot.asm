SECTION rom_code

INCLUDE "drive.h"

PUBLIC dummyRoot
dummyRoot:
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
