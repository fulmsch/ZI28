;;; Machine monitor, unstable and incomplete
;;TODO:
;;Change call to rst
;;Only allow printable chars as input
;
;INCLUDE "iomap.h"
;
;
;monitor:
;
;DEFC prgm = 0xc000
;
;	ld (stackSave), sp
;
;	ld sp, registerStack
;	push af
;	push bc
;	push de
;	push hl
;	push ix
;	push iy
;
;	ld sp, monStack
;
;	;ld hl, clearScreenStr
;	;call printStr
;	ld hl, welcomeStr
;	call printStr
;
;	ld ix, (stackSave)
;	ld a, (ix + 1)
;	call printbyte
;	ld a, (ix + 0)
;	call printbyte
;
;	ld hl, readyStr
;	call printStr
;
;prompt:
;	ld hl, monInputBuffer
;	ld c, 0
;
;	ld a, '>'
;	rst RST_putc
;
;handleChar:
;	xor a
;	rst RST_getc
;
;	cp 0x08
;	jr z, backspace
;
;	cp 0x0a
;	jr z, handleStr
;	cp 0x0d
;	jr z, handleChar
;	rst RST_putc
;
;;fix this hack when reworking the buffer system
;	ld b, a
;	ld a, l
;	cp monInputBufferSize - 1
;	jp nc, invalid
;	ld a, b
;	ld (hl), a
;	inc hl
;	inc c
;	jr handleChar
;
;backspace:
;	ld a, c
;	cp 0
;	jr z, handleChar
;	ld a, 0x08
;	rst RST_putc
;	ld a, 0x20
;	rst RST_putc
;	ld a, 0x08
;	rst RST_putc
;	dec hl
;	dec c
;	jr handleChar
;
;
;handleStr:
;	ld (hl), a
;	rst RST_putc
;	ld a, 0x0a
;	rst RST_putc
;
;	ld hl, monInputBuffer
;	ld a, (hl)
;	cp 0x0a
;	jp z, prompt ;no char entered
;
;	ld b, 0x00
;	inc hl
;	ld a, (hl)
;	cp 0x0a
;	jr z, handleStr02	;no arguments
;	cp ' '
;	jp nz, invalid
;
;handleStr00:
;	;get number of arguments
;	ld a, (hl)
;	cp 0x0a
;	jr z, handleStr02
;	cp ' '
;	jr z, handleStr01
;	inc hl
;	jr handleStr00
;handleStr01:
;	inc hl
;	ld a, (hl)
;	cp ' '
;	jr z, handleStr01
;	cp 0x0a
;	jr z, handleStr02
;	inc b
;	jr handleStr00
;
;handleStr02:
;	;ld a, b
;	;or 0x30
;	;rst RST_putc
;
;	ld a, (monInputBuffer)
;	call convertToUpper
;	cp '?'
;	jp z, help
;
;	cp 'C'
;	jp z, contPrgm
;
;	cp 'L'
;	jp z, loadPrgm
;
;	cp 'E'
;	jp z, execPrgm
;
;	cp 'J'
;	jp z, jump
;
;	cp 'D'
;	jp z, hexDump
;
;	cp 'W'
;	jp z, write
;
;	cp 'I'
;	jp z, ioIn
;
;	cp 'O'
;	jp z, ioOut
;
;	cp 'B'
;	jp z, bankSel
;
;	cp 'R'
;	jp z, register
;
;	jp invalid
;
;help:
;	ld a, b
;	cp 0x00
;	jp nz, invalid
;
;	ld hl, helpStr
;	call printStr
;	jp prompt
;
;
;contPrgm:
;	;Restore registers
;	ld sp, registerStackBot
;	pop iy
;	pop ix
;	pop hl
;	pop de
;	pop bc
;	pop af
;
;	ld sp, (stackSave)
;	inc sp
;	ret
;
;
;loadPrgm:
;	ld de, prgm	;replace with address field recognition
;	ld a, b
;	cp 0x00
;	jp z, load
;	cp 0x01
;	jp nz, invalid
;	
;	ld hl, monInputBuffer
;	call nextArg
;
;	call hexToNum16
;	jp nz, invalid
;
;load:
;	ld hl, loadStr
;	push de
;	call printStr
;	pop de
;	ld hl, 0x00
;
;waitForRecord:
;	xor a
;	rst RST_getc
;	cp 0x03
;	jp z, loadAbort
;	cp ':'
;	jr nz, waitForRecord
;	
;blockStart:
;	;Store the header in RAM
;	ld b, 8
;	ld hl, header
;headerLoop:
;	xor a
;	rst RST_getc
;	cp 0x03
;	jp z, loadAbort
;	ld (hl), a
;	inc hl
;	djnz headerLoop
;
;	;Check the record type, terminate if end-record
;	ld hl, recordTypeField
;	call hexToNum8
;	cp 1
;	jr z, loadExit
;	cp 0
;	jr nz, waitForRecord
;
;	;Get the byte count
;	ld hl, byteCountField
;	call hexToNum8
;	ld b, a
;	
;dataLoop:
;	xor a
;	rst RST_getc
;	cp 0x03
;	jp z, loadAbort
;	call hexToNumNibble
;	sla a
;	sla a
;	sla a
;	sla a
;	ld c, a
;	xor a
;	rst RST_getc
;	cp 0x03
;	jp z, loadAbort
;	call hexToNumNibble
;	or c
;	ld (de), a
;	inc de
;	djnz dataLoop
;	
;	jr waitForRecord
;	
;loadExit:
;	xor a
;	rst RST_getc
;	cp 0x03
;	jp z, loadAbort
;	cp 0x0a
;	jr nz, loadExit
;	
;
;loadEnd:
;	; ld 	a, h
;	; call printbyte
;	; ld a, l
;	; call printbyte
;  
;	ld hl, loadFinishedStr
;	call printStr
;	
;	jp prompt
;	
;loadAbort:
;	ld hl, loadAbortStr
;	call printStr
;	jr loadEnd
;	
;loadAbortStr:
;	DEFM "\nLoading aborted\n", 0x00
;
;
;execPrgm:
;	ld hl, prgm
;	ld a, b
;	cp 0x00
;	jp z, exec
;	cp 0x01
;	jp nz, invalid
;	
;	ld hl, monInputBuffer
;	call nextArg
;
;	call hexToNum16
;	jp nz, invalid
;	ld h, d
;	ld l, e
;
;exec:	
;	ld a, 0x0a
;	rst RST_putc
;	
;	ld de, execRtn
;	push de
;	jp (hl)
;execRtn:	
;	ld hl, doneStr
;	call printStr
;	jp prompt
;
;	
;jump:
;	ld a, b
;	cp 0x01
;	jp nz, invalid
;	
;	ld hl, monInputBuffer
;	call nextArg
;
;	call hexToNum16
;	jp nz, invalid
;	ld h, d
;	ld l, e
;
;	jp (hl)
;	
;	
;hexDump:
;	ld a, b
;	cp 0x01
;	jp nz, invalid
;	
;	ld hl, monInputBuffer
;	call nextArg
;
;	call hexToNum16
;	jp nz, invalid
;	
;	ld hl, hexDumpHeader
;	push de
;	call printStr
;	pop de
;
;hexDump00:
;	ld a, 16
;	ld (lineCounter), a
;	
;newline:	
;	ld a, d
;	call printbyte
;	ld a, e
;	call printbyte
;	ld a, ':'
;	rst RST_putc
;	ld b, 0x10
;	push de
;	
;line:
;	ld a, 0x20
;	rst RST_putc
;	ld a, (de)
;	call printbyte
;	inc de
;	djnz line
;	
;	ld a, 0x20
;	rst RST_putc
;	rst RST_putc
;	
;	pop de
;	ld b, 0x10
;
;text:	
;	ld a, (de)
;	cp 0x20
;	jr c, notPrintable
;	cp 0x7f
;	jr nc, notPrintable
;	jr hexDump01
;	
;notPrintable:
;	ld a, '.'
;
;hexDump01:
;	rst RST_putc
;	inc de
;	djnz text
;	
;
;	
;	ld b, 0x10
;	ld a, 0x0a
;	rst RST_putc
;
;	ld a, (lineCounter)
;	dec a
;	ld (lineCounter), a
;	cp 0x00
;	jr nz, newline
;	
;hexDumpContinue:
;	xor a
;	rst RST_getc
;	
;	cp 0x03 ;CTRL-C, break
;	jp z, prompt
;	cp 0x0a ;Enter, continue
;	jr nz, hexDumpContinue	
;	
;	ld a, 0x0a
;	rst RST_putc
;	jr hexDump00
;
;
;	
;printbyte:	
;	push af
;	and 0f0h
;	srl a
;	srl a
;	srl a
;	srl a
;	call nibbletoascii
;	rst RST_putc
;	pop af
;	and 0x0f
;	call nibbletoascii
;	rst RST_putc
;	ret
;
;nibbletoascii:
;	cp 10
;	jr c, num
;	sub 9
;	or 0x40
;	ret
;num:
;	or 0x30
;	ret
;	
;	
;hexDumpHeader:
;	DEFM "\n      00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F\n\n", 0x00
;
;write:
;	ld a, b
;	cp 0x01
;	jp nz, invalid
;	
;	ld hl, monInputBuffer
;	call nextArg
;
;	call hexToNum16
;	jp nz, invalid
;	
;	ld (monInputBuffer + 2), de
;
;
;writePrompt:
;	ld de, (monInputBuffer + 2)
;	ld a, d
;	call printbyte
;	ld a, e
;	call printbyte
;	ld a, 0x20
;	rst RST_putc
;	ld a, (de)
;	call printbyte
;	ld a, 0x20
;	rst RST_putc
;	
;	ld de, monInputBuffer
;	ld c, 0
;
;
;writeHandleChar:		
;	xor a
;	rst RST_getc
;	
;	cp 0x08
;	jr z, writeBackspace
;	cp 0x03
;	jr z, writeEnd
;	cp 0x0d
;	jr z, writeHandleChar
;	cp 0x0a
;	jr z, writeHandleStr
;	rst RST_putc
;	
;	ld b, a
;	ld a, c
;	cp 0x02
;	jp nc, writeInvalid
;	ld a, b
;	ld (de), a
;	inc de
;	inc c
;	jr writeHandleChar
;	
;writeBackspace:
;	ld a, c
;	cp 0
;	jr z, writeHandleChar
;	ld (hl), 0x08
;	ld (hl), 0x20
;	ld (hl), 0x08
;	dec de
;	dec c
;	jr writeHandleChar
;
;writeHandleStr:
;	ld a, 0x00
;	or c
;	jp z, writeNext ;no char entered
;
;	ld hl, monInputBuffer
;	call hexToNum8
;	jp nz, writeInvalid
;	
;	ld hl, (monInputBuffer + 2)
;
;	ld (hl), a
;
;	ld b, 0feh
;writeCheckSuccessLoop:
;	ld c, (hl)
;	cp c
;	jr z, write00
;	call delay500
;	djnz writeCheckSuccessLoop
;
;writeInvalid:
;	ld hl, writeErrorStr
;	call printStr
;	jp writePrompt
;
;write00:	
;	ld (monInputBuffer + 2), hl
;	
;	ld hl, writeOkStr
;	call printStr
;	
;writeNext:	
;	ld hl, (monInputBuffer + 2)
;	inc hl
;	ld (monInputBuffer + 2), hl
;	
;	ld a, 0x0a
;	rst RST_putc
;	jp writePrompt
;	
;
;
;writeEnd:
;	ld a, 0x0a
;	rst RST_putc
;	jp prompt
;	
;writeErrorStr:
;	DEFM " Error\n", 0x00
;	
;writeOkStr:
;	DEFM " Ok", 0x00
;
;ioIn:
;	ld a, b
;	cp 0x01
;	jp nz, invalid
;	
;	ld hl, monInputBuffer
;	call nextArg
;	call hexToNum8
;	jp nz, invalid
;	
;	ld c, a
;	in a, (c)
;	call printbyte
;	
;	ld a, 0x0a
;	rst RST_putc
;	
;	jp prompt
;	
;	
;ioOut:
;	ld a, b
;	cp 0x02
;	jp nz, invalid
;	
;	ld hl, monInputBuffer
;	call nextArg
;	call hexToNum8
;	jp nz, invalid
;	ld c, a
;	
;	call nextArg
;	call hexToNum8
;	jp nz, invalid
;	
;	out (c), a
;	
;	ld a, 0x0a
;	rst RST_putc
;	
;	jp prompt
;	
;
;
;
;bankSel:
;	ld a, b
;	cp 0x01
;	jp nz, invalid
;	
;	ld hl, monInputBuffer
;	call nextArg
;	call hexToNum8
;	jp nz, invalid
;	
;	cp 0x06
;	jp nc, invalid
;	
;	out (BANKSEL_PORT), a
;	
;	ld a, 0x0a
;	rst RST_putc
;	
;	jp prompt
;
;
;register:
;	ld a, b
;	cp 0x00
;;	jr z, showRegisters
;;	cp 0x03
;	jp nz, invalid
;	
;;	ld hl, monInputBuffer
;;	call nextArg
;;	inc hl
;;	ld a, (hl)
;;	cp ' '
;;	jp nz, invalid
;;	dec hl
;;	ld a, (hl)
;;
;;	call hexToNum8
;;	jp nz, invalid
;
;
;
;showRegisters:
;	ld hl, registerStr
;	call printStr
;
;	ld hl, registerStack
;	ld b, 6
;showRegisterLoop:
;	dec hl
;	ld a, (hl)
;	call printbyte
;	dec hl
;	ld a, (hl)
;	call printbyte
;	ld a, ' '
;	rst RST_putc
;	rst RST_putc
;	djnz showRegisterLoop
;
;	ld a, '\n'
;	rst RST_putc
;	jp prompt
;
;registerStr:
;	DEFM "\nAF    BC    DE    HL    IX    IY\n", 0x00
;
;
;invalid:
;	ld hl, invalidStr
;	call printStr
;	jp prompt
;
;
;;*****************
;;Delay500
;;
;;Description: Waits for 500ms
;;
;;Inputs: none
;;
;;Outputs: none
;;
;;Destroyed: bc
;delay500:
;	ld bc, 7aafh
;delay500Loop:
;	ex (sp), hl
;	ex (sp), hl
;	ex (sp), hl
;	ex (sp), hl
;	djnz delay500Loop
;	dec c
;	jr nz, delay500Loop
;	ret
;
;
;
;;*****************
;;HexToNum
;;
;;Description: Converts a hex string to a number
;;
;;Inputs: String starting at (hl)
;;
;;Outputs: a/de, zf=0: invalid
;;
;;Destroyed: hl, a
;hexToNum8:
;	ld a, (hl)
;	call hexToNumNibble
;	ret nz
;	ld (hl), a
;	inc hl
;	ld a, (hl)
;	call hexToNumNibble
;	ret nz
;	dec hl
;	rld
;	ld a, (hl)
;	cp a					;set zero flag
;	ret
;	
;hexToNum16:
;	call hexToNum8
;	ret nz
;	inc hl
;	inc hl
;	ld d, a
;	call hexToNum8
;	ret nz
;	ld e, a
;	
;	cp a					;set zero flag
;	ret
;	
;	
;;convert a single char to a number
;;zf=0 if invalid entry
;hexToNumNibble:				
;	cp 0x30					;check if it's a number
;	jr c, hexToNumNibble00 	;not a number
;	cp 0x40
;	jr c, hexToNumNibble01 	;number
;	
;hexToNumNibble00:			;check if it's a letter
;	call convertToUpper
;	cp 0x41
;	jr c, hexToNumNibbleInvalid
;	cp 0x47
;	jr nc, hexToNumNibbleInvalid
;	
;	add a, 0x09				;A -> 0x4A, F -> 0x4F
;hexToNumNibble01:
;	and 0x0f					;convert to number
;	cp a 					;set zero flag
;	ret
;hexToNumNibbleInvalid:
;	or 1 					;reset zero flag
;	ret
;	
;	
;;*****************
;;ConvertToUpper
;;
;;Description: Converts a char to uppercase
;;
;;Inputs: a
;;
;;Outputs: a
;;
;;Destroyed: none
;convertToUpper:
;	cp 0x61
;	ret c
;	cp 0x7b
;	ret nc
;	sub 0x20
;	ret
;	
;	
;;*****************
;;NextArg
;;
;;Description: Points hl to the beginning of the next argument
;;
;;Inputs: hl
;;
;;Outputs: hl
;;
;;Destroyed: hl
;nextArg:
;	ld a, (hl)
;	cp ' '
;	jr z, nextArgLoop
;	inc hl
;	jr nextArg
;nextArgLoop:
;	inc hl
;	ld a, (hl)
;	cp ' '
;	jr z, nextArgLoop
;	ret
;
;welcomeStr:
;	DEFM "\nExecution paused at ", 0x00
;
;readyStr:
;	DEFM "\nMonitor ready\n"
;	DEFM "Type '?' for help\n", 0x00
;
;helpStr:
;	DEFM "\n"
;	DEFM "C\t\tContinue execution of the program\n"
;	DEFM "L [ADDR]\tLoad an Intel-HEX file from USB\n"
;	DEFM "E [ADDR]\tExecute a program\n"
;	DEFM "J ADDR\t\tJump to a specific address\n"
;	DEFM "D ADDR\t\tDump 256 bytes of memory in hex format\n"
;	DEFM "W ADDR\t\tWrite to single bytes in memory\n"
;	DEFM "I PORT\t\tRead value from port\n"
;	DEFM "O PORT VAL\tWrite value to port\n"
;	DEFM "B BANK\t\tSelect memory bank 00-05\n"
;	DEFM "R\t\tShow and modify register contents\n", 0x00
;
;
;invalidStr:
;	DEFM "\nInvalid command\n"
;	DEFM "Type '?' for help\n", 0x00
;
;doneStr:
;	DEFM "\nDone\n", 0x00
;
;loadStr:
;	DEFM "\nLoading program\n", 0x00
;
;loadFinishedStr:
;	DEFM "h bytes transferred\n", 0x00
