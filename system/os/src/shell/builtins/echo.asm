SECTION rom_code
INCLUDE "os.h"
INCLUDE "string.h"
INCLUDE "cli.h"

PUBLIC b_echo

EXTERN putc

b_echo:
	;print all arguments
	ld a, (argc)
	dec a
	jr z, newline
	ld b, a
	ld de, argv
	inc de
	inc de

loop:
	ld a, (de)
	ld l, a
	inc de
	ld a, (de)
	ld h, a
	inc de
	push de
	push bc
	call print
	pop bc
	pop de
	ld a, ' '
	call putc
	djnz loop

newline:
	ld a, 0x0a
	call putc
	ret
