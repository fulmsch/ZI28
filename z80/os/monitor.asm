;TODO:
;Change call to rst
;Only allow printable chars as input


.func _monitor:

prgm	equ	0c000h

	ld (stackSave), sp

	ld sp, registerStack
	push af
	push bc
	push de
	push hl
	push ix
	push iy

	ld sp, monStack

	;ld hl, clearScreenStr
	;call printStr
	ld hl, welcomeStr
	call printStr

	ld ix, (stackSave)
	ld a, (ix + 1)
	call printbyte
	ld a, (ix + 0)
	call printbyte

	ld hl, readyStr
	call printStr

prompt:
	ld hl, monInputBuffer
	ld c, 0

	ld a, '>'
	call putc

handleChar:
	xor a
	call getc

	cp 08h
	jr z, backspace

	cp 0ah
	jr z, handleChar
	cp 0dh
	jr z, handleStr
	call putc

;fix this hack when reworking the buffer system
	ld b, a
	ld a, l
	cp monInputBufferSize - 1
	jp nc, invalid
	ld a, b
	ld (hl), a
	inc hl
	inc c
	jr handleChar

backspace:
	ld a, c
	cp 0
	jr z, handleChar
	ld a, 08h
	call putc
	ld a, 20h
	call putc
	ld a, 08h
	call putc
	dec hl
	dec c
	jr handleChar


handleStr:
	ld (hl), a
	call putc
	ld a, 0dh
	call putc
	ld a, 0ah
	call putc

	ld hl, monInputBuffer
	ld a, (hl)
	cp 0dh
	jp z, prompt ;no char entered

	ld b, 00h
	inc hl
	ld a, (hl)
	cp 0dh
	jr z, handleStr02	;no arguments
	cp ' '
	jp nz, invalid

handleStr00:
	;get number of arguments
	ld a, (hl)
	cp 0dh
	jr z, handleStr02
	cp ' '
	jr z, handleStr01
	inc hl
	jr handleStr00
handleStr01:
	inc hl
	ld a, (hl)
	cp ' '
	jr z, handleStr01
	cp 0dh
	jr z, handleStr02
	inc b
	jr handleStr00

handleStr02:
	;ld a, b
	;or 30h
	;call putc

	ld a, (monInputBuffer)
	call convertToUpper
	cp '?'
	jp z, help

	cp 'C'
	jp z, contPrgm

	cp 'L'
	jp z, loadPrgm

	cp 'E'
	jp z, execPrgm

	cp 'J'
	jp z, jump

	cp 'D'
	jp z, hexDump

	cp 'W'
	jp z, write

	cp 'I'
	jp z, ioIn

	cp 'O'
	jp z, ioOut

	cp 'B'
	jp z, bankSel

	cp 'R'
	jp z, register

	jp invalid

help:
	ld a, b
	cp 00h
	jp nz, invalid

	ld hl, helpStr
	call printStr
	jp prompt


contPrgm:
	;Restore registers
	ld sp, registerStackBot
	pop iy
	pop ix
	pop hl
	pop de
	pop bc
	pop af

	ld sp, (stackSave)
	inc sp
	ret


loadPrgm:
	ld de, prgm	;replace with address field recognition
	ld a, b
	cp 00h
	jp z, load
	cp 01h
	jp nz, invalid
	
	ld hl, monInputBuffer
	call nextArg

	call hexToNum16
	jp nz, invalid

load:
	ld hl, loadStr
	push de
	call printStr
	pop de
	ld hl, 00h

waitForRecord:
	xor a
	call getc
	cp 03h
	jp z, loadAbort
	cp ':'
	jr nz, waitForRecord
	
blockStart:
	;Store the header in RAM
	ld b, 8
	ld hl, header
headerLoop:
	xor a
	call getc
	cp 03h
	jp z, loadAbort
	ld (hl), a
	inc hl
	djnz headerLoop

	;Check the record type, terminate if end-record
	ld hl, recordTypeField
	call hexToNum8
	cp 1
	jr z, loadExit
	cp 0
	jr nz, waitForRecord

	;Get the byte count
	ld hl, byteCountField
	call hexToNum8
	ld b, a
	
dataLoop:
	xor a
	call getc
	cp 03h
	jp z, loadAbort
	call hexToNumNibble
	sla a
	sla a
	sla a
	sla a
	ld c, a
	xor a
	call getc
	cp 03h
	jp z, loadAbort
	call hexToNumNibble
	or c
	ld (de), a
	inc de
	djnz dataLoop
	
	jr waitForRecord
	
loadExit:
	xor a
	call getc
	cp 03h
	jp z, loadAbort
	cp 0dh
	jr nz, loadExit
	

loadEnd:
	; ld 	a, h
	; call printbyte
	; ld a, l
	; call printbyte
  
	ld hl, loadFinishedStr
	call printStr
	
	jp prompt
	
loadAbort:
	ld hl, loadAbortStr
	call printStr
	jr loadEnd
	
loadAbortStr:
	.db "\r\nLoading aborted\r\n", 00h 


execPrgm:
	ld hl, prgm
	ld a, b
	cp 00h
	jp z, exec
	cp 01h
	jp nz, invalid
	
	ld hl, monInputBuffer
	call nextArg

	call hexToNum16
	jp nz, invalid
	ld h, d
	ld l, e

exec:	
	ld a, 0dh
	call putc
	ld a, 0ah
	call putc
	
	ld de, execRtn
	push de
	jp (hl)
execRtn:	
	ld hl, doneStr
	call printStr
	jp prompt

	
jump:
	ld a, b
	cp 01h
	jp nz, invalid
	
	ld hl, monInputBuffer
	call nextArg

	call hexToNum16
	jp nz, invalid
	ld h, d
	ld l, e

	jp (hl)
	
	
hexDump:
	ld a, b
	cp 01h
	jp nz, invalid
	
	ld hl, monInputBuffer
	call nextArg

	call hexToNum16
	jp nz, invalid
	
	ld hl, hexDumpHeader
	push de
	call printStr
	pop de

hexDump00:
	ld a, 16
	ld (lineCounter), a
	
newline:	
	ld a, d
	call printbyte
	ld a, e
	call printbyte
	ld a, ':'
	call putc
	ld b, 10h
	push de
	
line:
	ld a, 20h
	call putc
	ld a, (de)
	call printbyte
	inc de
	djnz line
	
	ld a, 20h
	call putc
	call putc
	
	pop de
	ld b, 10h

text:	
	ld a, (de)
	cp 20h
	jr c, notPrintable
	cp 7fh
	jr nc, notPrintable
	jr hexDump01
	
notPrintable:
	ld a, '.'

hexDump01:
	call putc
	inc de
	djnz text
	

	
	ld b, 10h
	ld a, 0dh
	call putc
	ld a, 0ah
	call putc

	ld a, (lineCounter)
	dec a
	ld (lineCounter), a
	cp 00h
	jr nz, newline
	
hexDumpContinue:
	xor a
	call getc
	
	cp 03h ;CTRL-C, break
	jp z, prompt
	cp 0dh ;Enter, continue
	jr nz, hexDumpContinue	
	
	ld a, 0dh
	call putc
	ld a, 0ah
	call putc
	jr hexDump00


	
printbyte:	
	push af
	and 0f0h
	srl a
	srl a
	srl a
	srl a
	call nibbletoascii
	call putc
	pop af
	and 0fh
	call nibbletoascii
	call putc
	ret

nibbletoascii:
	cp 10
	jr c, num
	sub 9
	or 40h
	ret
num:
	or 30h
	ret
	
	
hexDumpHeader:
	.db "\r\n      00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F\r\n\r\n"
	.db 00h

write:
	ld a, b
	cp 01h
	jp nz, invalid
	
	ld hl, monInputBuffer
	call nextArg

	call hexToNum16
	jp nz, invalid
	
	ld (monInputBuffer + 2), de


writePrompt:
	ld de, (monInputBuffer + 2)
	ld a, d
	call printbyte
	ld a, e
	call printbyte
	ld a, 20h
	call putc
	ld a, (de)
	call printbyte
	ld a, 20h
	call putc
	
	ld de, monInputBuffer
	ld c, 0


writeHandleChar:		
	xor a
	call getc
	
	cp 08h
	jr z, writeBackspace
	cp 03h
	jr z, writeEnd
	cp 0dh
	jr z, writeHandleChar
	cp 0ah
	jr z, writeHandleStr
	call putc
	
	ld b, a
	ld a, c
	cp 02h
	jp nc, writeInvalid
	ld a, b
	ld (de), a
	inc de
	inc c
	jr writeHandleChar
	
writeBackspace:
	ld a, c
	cp 0
	jr z, writeHandleChar
	ld (hl), 08h
	ld (hl), 20h
	ld (hl), 08h
	dec de
	dec c
	jr writeHandleChar

writeHandleStr:
	ld a, 00h
	or c
	jp z, writeNext ;no char entered

	ld hl, monInputBuffer
	call hexToNum8
	jp nz, writeInvalid
	
	ld hl, (monInputBuffer + 2)

	ld (hl), a

	ld b, 0feh
writeCheckSuccessLoop:
	ld c, (hl)
	cp c
	jr z, write00
	call delay500
	djnz writeCheckSuccessLoop

writeInvalid:
	ld hl, writeErrorStr
	call printStr
	jp writePrompt

write00:	
	ld (monInputBuffer + 2), hl
	
	ld hl, writeOkStr
	call printStr
	
writeNext:	
	ld hl, (monInputBuffer + 2)
	inc hl
	ld (monInputBuffer + 2), hl
	
	ld a, 0dh
	call putc
	ld a, 0ah
	call putc
	jp writePrompt
	


writeEnd:
	ld a, 0dh
	call putc
	ld a, 0ah
	call putc
	jp prompt
	
writeErrorStr:
	db " Error\r\n"
	.db 00
	
writeOkStr:
	.db " Ok"
	.db 00

ioIn:
	ld a, b
	cp 01h
	jp nz, invalid
	
	ld hl, monInputBuffer
	call nextArg
	call hexToNum8
	jp nz, invalid
	
	ld c, a
	in a, (c)
	call printbyte
	
	ld a, 0dh
	call putc
	ld a, 0ah
	call putc
	
	jp prompt
	
	
ioOut:
	ld a, b
	cp 02h
	jp nz, invalid
	
	ld hl, monInputBuffer
	call nextArg
	call hexToNum8
	jp nz, invalid
	ld c, a
	
	call nextArg
	call hexToNum8
	jp nz, invalid
	
	out (c), a
	
	ld a, 0dh
	call putc
	ld a, 0ah
	call putc
	
	jp prompt
	



bankSel:
	ld a, b
	cp 01h
	jp nz, invalid
	
	ld hl, monInputBuffer
	call nextArg
	call hexToNum8
	jp nz, invalid
	
	cp 06h
	jp nc, invalid
	
	out (BANKSR), a
	
	ld a, 0dh
	call putc
	ld a, 0ah
	call putc
	
	jp prompt


register:
	ld a, b
	cp 00h
;	jr z, showRegisters
;	cp 03h
	jp nz, invalid
	
;	ld hl, monInputBuffer
;	call nextArg
;	inc hl
;	ld a, (hl)
;	cp ' '
;	jp nz, invalid
;	dec hl
;	ld a, (hl)
;
;	call hexToNum8
;	jp nz, invalid



showRegisters:
	ld hl, registerStr
	call printStr

	ld hl, registerStack
	ld b, 6
showRegisterLoop:
	dec hl
	ld a, (hl)
	call printbyte
	dec hl
	ld a, (hl)
	call printbyte
	ld a, ' '
	call putc
	call putc
	djnz showRegisterLoop

	ld a, '\r'
	call putc
	ld a, '\n'
	call putc
	jp prompt

registerStr:
	.asciiz "\r\nAF    BC    DE    HL    IX    IY\r\n"


invalid:
	ld hl, invalidStr
	call printStr
	jp prompt


;*****************
;Delay500
;
;Description: Waits for 500ms
;
;Inputs: none
;
;Outputs: none
;
;Destroyed: bc
delay500:
	ld bc, 7aafh
delay500Loop:
	ex (sp), hl
	ex (sp), hl
	ex (sp), hl
	ex (sp), hl
	djnz delay500Loop
	dec c
	jr nz, delay500Loop
	ret



;*****************
;HexToNum
;
;Description: Converts a hex string to a number
;
;Inputs: String starting at (hl)
;
;Outputs: a/de, zf=0: invalid
;
;Destroyed: hl, a
hexToNum8:
	ld a, (hl)
	call hexToNumNibble
	ret nz
	ld (hl), a
	inc hl
	ld a, (hl)
	call hexToNumNibble
	ret nz
	dec hl
	rld
	ld a, (hl)
	cp a					;set zero flag
	ret
	
hexToNum16:
	call hexToNum8
	ret nz
	inc hl
	inc hl
	ld d, a
	call hexToNum8
	ret nz
	ld e, a
	
	cp a					;set zero flag
	ret
	
	
;convert a single char to a number
;zf=0 if invalid entry
hexToNumNibble:				
	cp 30h					;check if it's a number
	jr c, hexToNumNibble00 	;not a number
	cp 40h
	jr c, hexToNumNibble01 	;number
	
hexToNumNibble00:			;check if it's a letter
	call convertToUpper
	cp 41h
	jr c, hexToNumNibbleInvalid
	cp 47h
	jr nc, hexToNumNibbleInvalid
	
	add a, 09h				;A -> 4Ah, F -> 4Fh
hexToNumNibble01:
	and 0fh					;convert to number
	cp a 					;set zero flag
	ret
hexToNumNibbleInvalid:
	or 1 					;reset zero flag
	ret
	
	
;*****************
;ConvertToUpper
;
;Description: Converts a char to uppercase
;
;Inputs: a
;
;Outputs: a
;
;Destroyed: none
convertToUpper:
	cp 61h
	ret c
	cp 7bh
	ret nc
	sub 20h
	ret
	
	
;*****************
;NextArg
;
;Description: Points hl to the beginning of the next argument
;
;Inputs: hl
;
;Outputs: hl
;
;Destroyed: hl
nextArg:
	ld a, (hl)
	cp ' '
	jr z, nextArgLoop
	inc hl
	jr nextArg
nextArgLoop:
	inc hl
	ld a, (hl)
	cp ' '
	jr z, nextArgLoop
	ret

;clearScreenStr:
;	.db 1bh
;	.db "[2J"
;	.db 1bh
;	.db "[H"
;	.db 00h

welcomeStr:
	.db "\r\nExecution paused at "
	.db 00h

readyStr:
	.db "\r\nMonitor ready\r\n"
	.db "Type '?' for help\r\n"
	.db 00h

helpStr:
	.db "\r\n"
	.db "C\t\tContinue execution of the program\r\n"
	.db "L [ADDR]\tLoad an Intel-HEX file from USB\r\n"
	.db "E [ADDR]\tExecute a program\r\n"
	.db "J ADDR\t\tJump to a specific address\r\n"
	.db "D ADDR\t\tDump 256 bytes of memory in hex format\r\n"
	.db "W ADDR\t\tWrite to single bytes in memory\r\n"
	.db "I PORT\t\tRead value from port\r\n"
	.db "O PORT VAL\tWrite value to port\r\n"
	.db "B BANK\t\tSelect memory bank 00-05\r\n"
	.db "R\t\tShow and modify register contents\r\n"
	.db 00h


invalidStr:
	.db "\r\nInvalid command\r\n"
	.db "Type '?' for help\r\n"
	.db 00h

doneStr:
	.db "\r\nDone\r\n"
	.db 00h

loadStr:
	.db "\r\nLoading program\r\n"
	.db 00h

loadFinishedStr:
	.db "h bytes transferred\r\n"
	.db 00h
.endf ;_monitor
