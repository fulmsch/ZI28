SECTION rom_code
INCLUDE "os.h"
INCLUDE "string.h"
INCLUDE "cli.h"

EXTERN version
EXTERN putc

PUBLIC b_ver
b_ver:
	ld a, (argc)
	cp 1
	jr nz, invalidCall

	ld hl, version
	call print
	ld a, 0x0a
	jp putc

invalidCall:
	ret
