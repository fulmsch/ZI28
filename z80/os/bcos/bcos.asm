;****************************
;Basic Card Operating System
;Florian Ulmschneider 2016


include "biosCalls.h"
include "bcosCalls.h"

sdBuffer: equ 4200h

	org bcosVect
	;TODO check if c is valid
	ld hl, .bcosVectTable
	ld b, 0
	add hl, bc
	add hl, bc

	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	jp (hl)

.bcosVectTable:

.bcosStart:

	;TODO setup stack and interrupts

	call initfs

include "fat.asm"
