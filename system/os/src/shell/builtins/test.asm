SECTION rom_code
INCLUDE "cli.h"

EXTERN fontTable

PUBLIC b_test
b_test:
	ld a, (argc)
	cp 2
	ret nz

	ld hl, argv
	inc hl
	inc hl

	ld e, (hl)
	inc hl
	ld d, (hl)
	;(de) = string

	xor a
	ld (xOffs), a
	ld (yOffs), a
	out (0x93), a

loop:
	ld a, (de)
	cp 0
	ret z

	push de

	ld hl, fontTable
	ld c, a
	ld b, 0

	sla c
	rl b
	sla c
	rl b
	sla c
	rl b

	adc hl, bc
	;(hl): font table entry
	ld b, 8

vLoop:
	ld a, 8
	sub a, b
	out (0x92), a ;yreg
	ld a, (xOffs)
	out (0x91), a ;xreg

	ld d, (hl)
	inc hl

	ld c, 3
hloop:
	ld a, 0 ;set both pixels to black
	rlc d
	jr nc, blank0
	or 0x0f
blank0:
	rlc d
	jr nc, blank1
	or 0xf0
blank1:
	out (0x97), a ;data inc

	dec c
	jr nz, hloop



	djnz vLoop


	pop de
	inc de
	ld hl, xOffs
	ld a, 3
	add a, (hl)
	ld (hl), a
	jr loop
	ret

SECTION ram_os
xOffs: defb 0
yOffs: defb 0
