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
	dw _openFile
	dw _closeFile
	dw _readFile
;	dw fatReadFile


.bcosStart:

	;TODO setup stack and interrupts
	ld sp, 8000h

	call initfs
	ld de, .shellPath
	call _openFile
	ld a, e
	ld de, 0c000h
	ld hl, 0ffffh
	call _readFile
	call 0c000h
	jp 0
	
.shellPath:
	db "/BIN/CLI.BIN\0"


include "fat.asm"
include "file.asm"
