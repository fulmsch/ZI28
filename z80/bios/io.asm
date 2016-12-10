;TODO:
;Every device should be represented by one bit, so that multiple devices may be selected

_putc:
	;Output a byte in A to the selected device
	push af
	ld a, (outputDev)

putcUSB:
	in a, (TERMCR)
	bit 0, a
	jr nz, putcUSB
	pop af
	out (TERMDR), a
	ret


_setOutput:
	;Set the output device used by putc
	;0: USB
	cp 1
	ret nc
	ld (outputDev), a
	ret


_getc:
	;Get a byte from the selected device
	;A = 0: blocking
	;A = 1: Z=1 indicates available data
	push af
	ld a, (inputDev)

getcUSB:
	pop af
	or 0
	jr z, getcUSBBlocking
	in a, (TERMCR)
	bit 1, a
	ret
getcUSBBlocking:
	in a, (TERMCR)
	bit 1, a
	jr nz, getcUSBBlocking
	in a, (TERMDR)
	ret


_setInput:
	;Set the input device used by getc
	;0: USB
	cp 1
	ret nc
	ld (inputDev), a
	ret


;*****************
;PrintString
;
;Description: Prints a zero-terminated string starting at hl to the terminal
;
;Inputs: String starting at (hl)
;
;Outputs: String at terminal
;
;Destroyed: hl, a
printStr:
	ld a, (hl)
	cp 00h
	ret z
	call putc
	inc hl
	jr printStr

