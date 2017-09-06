.z80

.define TERMDR 00h
.define TERMCR 01h

;TODO:
;Change destination address
;Enable data protecion


.org 0c000h

	ld hl, clearScreenStr
	call printStr
	ld hl, welcomeStr
	call printStr

prompt:
	ld hl, promptStr
	call printStr

	call waitForInput
	and 5fh		;convert to uppercase

	cp 'L'
	jp z, load
	cp 'C'
	jp z, clear
	cp 'V'
	jp z, verify
	cp 'B'
	jp z, burn
	cp 'R'
	jp z, reset

	jr prompt


header:
byteCountField: 	dw 0
addressField:		dw 0,0
recordTypeField:	dw 0


load:
	ld de, 0e000h

	ld hl, loadStr
	call printStr

waitForRecord:
	call waitForInput
	cp 03h
	jp z, loadAbort
	cp ':'
	jr nz, waitForRecord
	
blockStart:
	;Store the header in RAM
	ld b, 8
	ld hl, header
headerLoop:
	call waitForInput
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
	call waitForInput
	cp 03h
	jp z, loadAbort
	call hexToNumNibble
	sla a
	sla a
	sla a
	sla a
	ld c, a
	call waitForInput
	cp 03h
	jp z, loadAbort
	call hexToNumNibble
	or c
	ld (de), a
	inc de
	djnz dataLoop
	
	jr waitForRecord
	
loadExit:
	call waitForInput
	cp 03h
	jp z, loadAbort
	cp 0ah
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

loadStr:
	.db "\nLoading\n"
	.db 00h

loadFinishedStr:
	.db "Finished loading\n"
	.db 00h

loadAbortStr:
	.db "Loading aborted\n"
	.db 00h



clear:
	ld hl, clearConfirmationStr
	call printStr

clear00:
	call waitForInput
	and 5fh		;convert to uppercase

	cp 'N'
	jp z, prompt
	cp 'Y'
	jr nz, clear00

	ld a, 00h
	ld hl, 0e000h

clearLoop:
	ld (hl), a
	inc hl
	cp h
	jr nz, clearLoop

	ld hl, clearCompleteStr
	call printStr
	jp prompt

clearConfirmationStr:
	.db "\nClear the entire buffer? [Y/N]\n"
	.db 00h

clearCompleteStr:
	.db "\nThe buffer has been cleared\n"
	.db 00h



verify:
	ld hl, verifySelectStr
	call printStr

verify00:
	call waitForInput
	and 5fh		;convert to uppercase

	cp 'C'
	jp z, prompt
	cp 'B'
	jr z, verifyBuffer
	cp 'R'
	jr nz, verify00

	ld de, 0000h
	ld b, 20h
	jr verifyStart

verifyBuffer:
	ld de, 0e000h
	ld b, 00h	

verifyStart:
	ld hl, verifyStartStr
	call printStr

verify01:
	call waitForInput
	cp 3
	jp z, prompt
	cp 5
	jr nz, verify01

verifyUploadLoop:
	ld a, (de)
	out (TERMDR), a
	inc de
	call verifyCheckCancel
	ld a, b
	cp d
	jr nz, verifyUploadLoop

	jp prompt

verifyCheckCancel:
	in a, (TERMCR)
	bit 1, a
	ret nz
	cp 3
	ret nz
	pop hl
	ld hl, verifyCancelStr
	call printStr
	jp prompt

verifySelectStr:
	.db "\nSelect source:\n"
	.db "[B]uffer    [R]OM    [C]ancel\n"
	.db 00h

verifyStartStr:
	.db "\nWaiting for start signal\n"
	.db 00h

verifyCancelStr:
	.db "Transfer canceled\n"
	.db 00h



burn:
	ld hl, burnConfirmationStr
	call printStr

burn00:
	call waitForInput
	and 5fh		;convert to uppercase

	cp 'N'
	jp z, prompt
	cp 'Y'
	jr nz, burn00


	ld de, 0000h
	ld hl, 0e000h

burnLoop:
	;Data protection bytes
	ld a, 0aah
	ld (1555h), a
	ld a, 55h
	ld (0aaah), a
	ld a, 0a0h
	ld (1555h), a

	ld bc, 63
	ldir

	;The last byte is copied manually, to keep the value in A

	ld a, (hl)
	ld (de), a

	;Then keep reading that last byte until it matches A, as this
	;is how the EEPROM indicates when programming is complete.

burnWait:
	ld a, (de)
	cp (hl)
	jr nz, burnWait

	;Increment the EEPROM address, for that last byte.

	inc hl
	inc de

	;If we haven't reached address 2000h, then repeat, so
	;as to program the rest of the EEPROM, 64 bytes a at a time.

	xor a
	or h

	jr nz, burnLoop

	jp prompt

burnConfirmationStr:
	.db "\nBurn the contents of the buffer to the ROM? [Y/N]\n"
	.db 00h



reset:
	ld hl, resetConfirmationStr
	call printStr

reset00:
	call waitForInput
	and 5fh		;convert to uppercase

	cp 'N'
	jp z, prompt
	cp 'Y'
	jr nz, reset00

	jp 0000h

resetConfirmationStr:
	.db "\nReset the system? [Y/N]\n"
	.db 00h


clearScreenStr:
	.db 1bh
	.db "[2J"
	.db 1bh
	.db "[H"
	.db 00h

welcomeStr:
	.db "RomUtil - Program to write to and verify the EEPROM\n"
	.db "F. Ulmschneider 2016\n"
	.db 00h

promptStr:
	.db "\n[L]oad    [C]lear    [V]erify    [B]urn    [R]eset\n"
	.db 00h


;*****************
;CheckInput
;
;Description: Checks wether data is available from the terminal
;
;Inputs: none
;
;Outputs: Available data: zf = 1
;
;Destroyed: A
checkInput:
	in a, (TERMCR)
	bit 1, a
	ret


;*****************
;WaitForInput
;
;Description: Waits for an input from the terminal
;
;Inputs: none
;
;Outputs: Received byte in A
;
;Destroyed: A
waitForInput:
	in a, (TERMCR)
	bit 1, a
	nop
	nop
  nop
	jr nz, waitForInput
	in a, (TERMDR)
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
	out (TERMDR), a
	inc hl
	jr printStr
	
	
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
	
