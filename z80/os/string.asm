.list
;; strings.asm
;; Contains string manipulation routines similar to those in the C library "string.h"
;;
;; Calling conventions:
;;  de = destination / str1
;;  hl = source / str2
;;  a  = char / len


.func memcmp:
;; Description: Compares b bytes of hl and de
;; Input: de, hl: Pointers
;; Output: z if equal
;; Destroyed: a, bc, de, hl

	ld a, (de)
	ld c, a
	ld a, (hl)
	cp c
	ret nz
	inc de
	inc hl
	djnz memcmp
	ret
.endf ;memcmp


.func memset:
;; Description: Fills b bytes with a, starting at hl
;; Input: a: value; hl: Pointer; b: count
;; Output: none
;; Destroyed:

	ld (hl), a
	inc hl
	djnz memset
	ret
.endf ;memset


.func strcat:
;; Description: Appends hl to the end of de
;; Input: de, hl: String pointers
;; Output: none
;; Destroyed: a, de, hl

	;Find the end of (de)
srcloop:
	ld a, (de)
	cp 0
	inc de
	jr nz, srcloop
	dec de

	;Copy hl to de
	jp strcpy
.endf ;strcat


.func strncat:
;; Description: Appends up to b characters from hl to the end of de
;; Input: de, hl: String pointers
;; Output: none
;; Destroyed: a, b, de, hl

	;Find the end of (de)
srcloop:
	ld a, (de)
	cp 0
	inc de
	jr nz, srcloop
	dec de

	jp strncpy
.endf ;strncat


.func strcmp:
;; Description: Compares hl and de
;; Input: de, hl: String pointers
;; Output: z if equal strings
;; Destroyed: a, b, de, hl

	ld a, (de)
	ld b, a
	ld a, (hl)
	cp b
	ret nz
	cp 00h
	ret z
	inc de
	inc hl
	jr strcmp
.endf ;strcmp


.func strncmp:
;; Description: Compares at most the first b characters of hl and de
;; Input: de, hl: String pointers; b: length
;; Output: z if equal strings
;; Destroyed: a, bc, de, hl

	ld a, (de)
	ld c, a
	ld a, (hl)
	cp c
	ret nz
	cp 0
	ret z
	inc de
	inc hl
	djnz strncmp
	ret
.endf ;strncmp


.func strcpy:
;; Description: Copy hl to de
;; Input: de, hl: String pointers
;; Output: none
;; Destroyed: a, de, hl

	ld a, (hl)
	ld (de), a
	cp 00h
	ret z
	inc hl
	inc de
	jr strcpy
.endf ;strcpy


.func strncpy:
;; Description: Copy up to b characters from hl to de
;; Input: de, hl: String pointers; b: length
;; Output: none
;; Destroyed: a, b, de, hl

	ld a, (hl)
	ld (de), a
	cp 0
	ret z
	inc hl
	inc de
	djnz strncpy
	ret
.endf ;strncpy


.func strlen:
;; Description: Returns the length of the string pointed to by hl
;;              not including the null terminator
;; Input: hl: String pointer
;; Output: bc
;; Destroyed: hl
	ld bc, 0
loop:
	ld a, (hl)
	cp 0
	ret z
	inc bc
	inc hl
	jr loop
.endf ;strlen


.func toupper:
;; Description: Converts a to uppercase
;; Input: a: char
;; Output: a
;; Destroyed: 

	cp 61h
	ret c
	cp 7bh
	ret nc
	sub 20h
	ret
.endf ;toupper


.func strtup:
;; Description: Converts hl to uppercase
;; Input: hl: String pointer
;; Output: none
;; Destroyed:

	ld a, (hl)
	cp 0
	ret z

	call toupper
	ld (hl), a
	inc hl
	jr strtup
.endf ;strtup


;*****************
;PrintString
;Description: Prints a zero-terminated string starting at hl to the terminal
;Inputs: String starting at (hl)
;Outputs: String at terminal
;Destroyed: hl, a
.func printStr:
	push hl
	call strlen
	ld h, b
	ld l, c
	pop de
	ld a, (terminalFd)
	jp k_write
;	ld a, (hl)
;	cp 00h
;	ret z
;	rst putc
;	inc hl
;	jr printStr
.endf ;printStr
