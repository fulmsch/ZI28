.list


;****************
;String Compare
;Description: Compares two strings
;Inputs: de, hl: String pointers
;Outputs: z if equal strings
;Destroyed: a, b
.func strCompare:
	ld a, (de)
	ld b, a
	ld a, (hl)
	cp b
	ret nz
	cp 00h
	ret z
	inc de
	inc hl
	jr strCompare
.endf ;strCompare


;****************
;String Copy
;Description: Copies a string from one location to another
;Inputs: hl: origin, de: destination
;Outputs: de, hl: point to the null terminators
;Destroyed: a
.func strCopy:
	ld a, (hl)
	ld (de), a
	cp 00h
	ret z
	inc hl
	inc de
	jr strCopy
.endf ;strCopy


;*****************
;ConvertToUpper
;Description: Converts a string to uppercase
;Inputs: hl: String pointer
;Outputs:
;Destroyed: none
.func convertToUpper:
	ld a, (hl)
	cp 0
	ret z

	cp 61h
	jr c, convertToUpper00
	cp 7bh
	jr nc, convertToUpper00
	sub 20h
	ld (hl), a
convertToUpper00:
	inc hl
	jr convertToUpper
.endf ;convertToUpper


;*****************
;PrintString
;Description: Prints a zero-terminated string starting at hl to the terminal
;Inputs: String starting at (hl)
;Outputs: String at terminal
;Destroyed: hl, a
.func printStr:
	ld a, (hl)
	cp 00h
	ret z
	rst putc
	inc hl
	jr printStr
.endf ;printStr
