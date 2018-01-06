SECTION rom_code
INCLUDE "os.h"
INCLUDE "string.h"

EXTERN dispatchTable

PUBLIC b_help
b_help:
	ld hl, helpMsg
	call print
	;print commands from dispatch table
	ld bc, dispatchTable
tableLoop:
	ld a, (bc)
	ld l, a
	inc bc
	ld a, (bc)
	ld h, a
	inc bc
	inc bc
	inc bc
	ld a, (hl)
	cp 00h
	jr z, path
	ld a, ' '
	rst RST_putc
	push bc
	call print
	pop bc
	ld a, 0dh
	rst RST_putc
	ld a, 0ah
	rst RST_putc
	jr tableLoop

path:
;	ld hl, pathMsg
;	call print
;	;print the path
;	xor a
;	ld (cliProgramName), a
;	ld hl, programPath
;	call print

;	ld a, 0dh
;	rst RST_putc
;	ld a, 0ah
;	rst RST_putc

	ret

helpMsg:
	DEFM "The following commands are available:\n", 0x00
pathMsg:
	DEFM "\nAdditional programs will be searched in:\n ", 0x00
