SECTION rom_code
INCLUDE "os.h"
INCLUDE "string.h"
INCLUDE "cli.h"

EXTERN k_getcwd

PUBLIC b_pwd
b_pwd:
	ld a, (argc)
	cp 1
	jr nz, invalidCall

	ld hl, pathBuffer
	push hl
	call k_getcwd
	pop hl
	call print
	ld a, 0x0a
	jp RST_putc


invalidCall:
	ret
