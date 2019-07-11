SECTION rom_code

INCLUDE "drivers/vt100.h"

PUBLIC vt100_init

EXTERN kalloc

vt100_init:
;; Input:
;; : (de) - custom data start (screenBuffer)
	ld hl, 2016 ; 42 x 24 characters, 2 bytes / character
	call kalloc
	cp 0
	ret nz

	ex de, hl
	ld (hl), e
	inc de
	ld (hl), d

	;clear screen buffer
	ld h, d
	ld l, e
	inc de
	ld bc, 2015
	ld (hl), 0x00
	ldir

	ret
