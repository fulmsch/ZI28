;****************************
;Basic Card Operating System
;Florian Ulmschneider 2016


include "biosCalls.h"
include "bcosCalls.h"

sdBuffer: equ 4200h

	org 5000h
	jp _bcosStart
	;TODO check if c is valid
	push af
	push hl
	ld hl, .bcosVectTable
	ld b, 0
	add hl, bc
	add hl, bc

	ld a, (hl)
	ld ixl, a
	inc hl
	ld a, (hl)
	ld ixh, a
	pop hl
	pop af
	jp (ix)

.bcosVectTable:
	dw _bcosStart
	dw _openFile
	dw _closeFile
	dw _readFile
;	dw fatReadFile


_bcosStart:

	;TODO setup stack and interrupts
	ld sp, 8000h

	call initfs
	ld de, .shellPath
	call _openFile
	ld a, e
	ld de, 6000h
	ld hl, 0ffffh
	call _readFile
	call 6000h
	jp 0
	
.shellPath:
	db "/SYS/CLI.BIN\0"


include "fat.asm"
include "file.asm"
