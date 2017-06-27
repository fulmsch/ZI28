;; Contains string manipulation routines similar to those in the C library "string.h"
;;
;; Calling convention:
;; : de - destination / str1
;; : hl - source / str2
;; : a  - char / len
.list


.func memcmp:
;; Compares b bytes of hl and de
;;
;; Input:
;; : de, hl - pointers
;;
;; Output:
;; : z if equal
;;
;; Destroyed:
;; : a, bc, de, hl

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
;; Fills b bytes with a, starting at hl
;;
;; Input:
;; : a - value
;; : hl - pointer
;; : b - count

	ld (hl), a
	inc hl
	djnz memset
	ret
.endf ;memset


.func strcat:
;; Appends hl to the end of de
;;
;; Input:
;; : de, hl - string pointers
;;
;; Destroyed:
;; : a, de, hl

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
;; Appends up to b characters from hl to the end of de
;;
;; Input:
;; : de, hl - string pointers
;;
;; Destroyed:
;; : a, b, de, hl

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
;; Compares hl and de
;;
;; Input:
;; : de, hl - string pointers
;;
;; Output:
;; : z if equal strings
;;
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
;; Compares at most the first b characters of hl and de
;;
;; Input:
;; : de, hl - string pointers
;; : b - length
;;
;; Output:
;; : z if equal strings
;;
;; Destroyed:
;; : a, bc, de, hl

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
;; Copy a string from hl to de
;;
;; Input:
;; : de, hl - string pointers
;;
;; Destroyed:
;; : a, de, hl

	ld a, (hl)
	ld (de), a
	cp 00h
	ret z
	inc hl
	inc de
	jr strcpy
.endf ;strcpy


.func strncpy:
;; Copy up to b characters from hl to de
;;
;; Input:
;; : de, hl - string pointers
;; : b - length
;;
;; Destroyed:
;; : a, b, de, hl

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
;; Returns the length of the string pointed to by hl
;;
;; Input:
;; : hl - string pointer
;;
;; Output:
;; : bc - length not including the null terminator
;;
;; Destroyed:
;; : hl

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
;; Converts a character to uppercase
;;
;; Input:
;; : a - char

	cp 61h
	ret c
	cp 7bh
	ret nc
	sub 20h
	ret
.endf ;toupper


.func strtup:
;; Converts a string to uppercase
;;
;; Input:
;; : hl - string pointer
;;
;; Destroyed:
;; : a, hl

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
	ld a, STDOUT_FILENO
	jp k_write
;	ld a, (hl)
;	cp 00h
;	ret z
;	rst putc
;	inc hl
;	jr printStr
.endf ;printStr
