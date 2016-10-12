;BIOS v0.1
;Bootstrapper and basic I/O-Routines
;Florian Ulmschneider 2016

;TODO:


include "iomap.h"
include "bios_memmap.h"
include "biosCalls.h"


; Jump Table -------------------------------------------------

	org memBase

	jp		_bootloader		;RST 00h
	db		00h
	jp		00h				;CALL 04h
	db		00h
	jp		_putc			;RST 08h
	db		00h
	jp		_setOutput		;CALL 0Ch
	db		00h
	jp		_getc			;RST 10h
	db		00h
	jp		_setInput		;CALL 14h
	db		00h
	jp		00h				;RST 18h
	db		00h
	jp		00h				;CALL 1Ch
	db		00h
	jp		_sdRead			;RST 20h
	db		00h
	jp		00h				;CALL 24h
	db		00h
	jp		00h				;RST 28h
	db		00h
	jp		00h				;CALL 2Ch
	db		00h
	jp		00h				;RST 30h
	db		00h
	jp		00h				;CALL 34h
	db		00h
	jp		_monitor		;RST 38h



	ds nmiEntry - $, 0

	dw ISR_keyboard

; BIOS-Routines ----------------------------------------------

include "io.asm"
include "interrupt.asm"
include "sd.asm"


; Bootloader -------------------------------------------------

_bootloader:
	ld sp, sysStack

	;Set input and output to USB
	xor a
	call setOutput
	call setInput

	call sdInit

	xor a
	ld b, a
	ld c, a
	ld d, a
	ld e, a
	ld a, 1
	ld hl, 0c000h
	call _sdRead

	ld hl, (0c000h)
	ld a, l
	cp 18h
	jr nz, invalidMBR
	ld a, h
	or a
	jr nz, invalidMBR
	ld hl, (0c1feh)
	ld a, l
	cp 55h
	jr nz, invalidMBR
	ld a, h
	cp 0aah
	jr nz, invalidMBR

	jp 0c000h

invalidMBRStr:
	db "Error: Invalid MBR signature\r\n\0"

invalidMBR:
	ld hl, invalidMBRStr
	call printStr
	call _monitor
	call coldStart


; Monitor ----------------------------------------------------

include "monitor.asm"

