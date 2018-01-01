DEFC FT240_DATA_PORT   = 0x00
DEFC FT240_STATUS_PORT = 0x01
DEFC BANK_PORT         = 0x02

;TODO:
;Enable data protecion


ORG 0x8000

	ld hl, clearScreenStr
	call printStr
	ld hl, welcomeStr
	call printStr

prompt:
	ld hl, promptStr
	call printStr

	call waitForInput
	and 0x5f		;convert to uppercase

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
byteCountField:
	DEFW 0x0000
addressField:
	DEFW 0x0000, 0x0000
recordTypeField:
	DEFW 0x0000


load:
	ld de, 0xc000

	ld hl, loadStr
	call printStr

waitForRecord:
	call waitForInput
	cp 0x03
	jp z, loadAbort
	cp ':'
	jr nz, waitForRecord
	
blockStart:
	;Store the header in RAM
	ld b, 8
	ld hl, header
headerLoop:
	call waitForInput
	cp 0x03
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
	cp 0x03
	jp z, loadAbort
	call hexToNumNibble
	sla a
	sla a
	sla a
	sla a
	ld c, a
	call waitForInput
	cp 0x03
	jp z, loadAbort
	call hexToNumNibble
	or c
	ld (de), a
	inc de
	djnz dataLoop
	
	jr waitForRecord
	
loadExit:
	call waitForInput
	cp 0x03
	jp z, loadAbort
	cp 0x0a
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
	DEFM "\r\nLoading\r\n", 0x00

loadFinishedStr:
	DEFM "Finished loading\r\n", 0x00

loadAbortStr:
	DEFM "Loading aborted\r\n", 0x00



clear:
	ld hl, clearConfirmationStr
	call printStr

clear00:
	call waitForInput
	and 0x5f ;convert to uppercase

	cp 'N'
	jp z, prompt
	cp 'Y'
	jr nz, clear00

	ld a, 0x00
	ld hl, 0xc000

clearLoop:
	ld (hl), a
	inc hl
	cp h
	jr nz, clearLoop

	ld hl, clearCompleteStr
	call printStr
	jp prompt

clearConfirmationStr:
	DEFM "\r\nClear the entire buffer? [Y/N]\r\n", 0x00

clearCompleteStr:
	DEFM "\r\nThe buffer has been cleared\r\n", 0x00



verify:
	ld hl, verifySelectStr
	call printStr

verify00:
	call waitForInput
	and 0x5f ;convert to uppercase

	cp 'C'
	jp z, prompt
	cp 'B'
	jr z, verifyBuffer
	cp 'R'
	jr nz, verify00

	ld de, 0x0000
	ld b, 0x20
	jr verifyStart

verifyBuffer:
	ld de, 0xc000
	ld b, 0x00

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
	out (FT240_DATA_PORT), a
	inc de
	call verifyCheckCancel
	ld a, b
	cp d
	jr nz, verifyUploadLoop

	jp prompt

verifyCheckCancel:
	in a, (FT240_STATUS_PORT)
	bit 1, a
	ret nz
	cp 3
	ret nz
	pop hl
	ld hl, verifyCancelStr
	call printStr
	jp prompt

verifySelectStr:
	DEFM "\r\nSelect source:\r\n"
	DEFM "[B]uffer    [R]OM    [C]ancel\r\n", 0x00

verifyStartStr:
	DEFM "\r\nWaiting for start signal\r\n", 0x00

verifyCancelStr:
	DEFM "Transfer canceled\r\n", 0x00



burn:
	ld hl, burnConfirmationStr
	call printStr

burn00:
	call waitForInput
	and 0x5f ;convert to uppercase

	cp 'N'
	jp z, prompt
	cp 'Y'
	jr nz, burn00


	ld hl, 0xc000
	ld de, 0x0000

burnLoop:
	;Data protection bytes
	ld a, 0xaa
	ld (0x1555), a
	ld a, 0x55
	ld (0xaaa), a
	ld a, 0xa0
	ld (0x1555), a

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
	DEFM "\r\nBurn the contents of the buffer to the ROM? [Y/N]\r\n", 0x00



reset:
	ld hl, resetConfirmationStr
	call printStr

reset00:
	call waitForInput
	and 0x5f ;convert to uppercase

	cp 'N'
	jp z, prompt
	cp 'Y'
	jr nz, reset00

	jp 0x0000

resetConfirmationStr:
	DEFM "\r\nReset the system? [Y/N]\r\n", 0x00


clearScreenStr:
	DEFM 0x1b, "[2J"
	DEFM 0x1b, "[H", 0x00

welcomeStr:
	DEFM "RomUtil - Program to write to and verify the EEPROM\r\n"
	DEFM "F. Ulmschneider 2016\r\n", 0x00

promptStr:
	DEFM "\r\n[L]oad    [C]lear    [V]erify    [B]urn    [R]eset\r\n", 0x00


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
	in a, (FT240_STATUS_PORT)
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
	in a, (FT240_STATUS_PORT)
	bit 1, a
	nop
	nop
  nop
	jr nz, waitForInput
	in a, (FT240_DATA_PORT)
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
	cp 0x00
	ret z
	out (FT240_DATA_PORT), a
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
	cp a ;set zero flag
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
	
	cp a ;set zero flag
	ret
	
	
;convert a single char to a number
;zf=0 if invalid entry
hexToNumNibble:				
	cp 0x30                 ;check if it's a number
	jr c, hexToNumNibble00  ;not a number
	cp 0x40
	jr c, hexToNumNibble01  ;number
	
hexToNumNibble00:           ;check if it's a letter
	call convertToUpper
	cp 0x41
	jr c, hexToNumNibbleInvalid
	cp 0x47
	jr nc, hexToNumNibbleInvalid
	
	add a, 0x09             ;A -> 0x4A, F -> 0x4F
hexToNumNibble01:
	and 0x0f                ;convert to number
	cp a                    ;set zero flag
	ret
hexToNumNibbleInvalid:
	or 1                    ;reset zero flag
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
	cp 0x61
	ret c
	cp 0x7b
	ret nc
	sub 0x20
	ret
	
