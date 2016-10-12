;****************************
;Basic Card Operating System
;Florian Ulmschneider 2016


include "biosCalls.h"
include "bcosCalls.h"

sdBuffer: equ 4200h

	org bcosVect
	jp .bcosStart
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
	dw .bcosStart

.bcosStart:

	;TODO setup stack and interrupts

	call initfs

	ret

include "fat.asm"
