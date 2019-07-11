SECTION rom_code
INCLUDE "os.h"

PUBLIC printDec16, printDec8

EXTERN k_write, strlen

;TODO suppress leading zeros

printDec8:
;; Print an unsigned 8-bit integer to stdout.
;;
;; Input:
;; : a - number

	ld l, a
	ld h, 0

printDec16:
;; Print an unsigned 16-bit integer to stdout.
;;
;; Input:
;; : hl - number

	ld bc, -10000
	call Num1
	ld bc, -1000
	call Num1
	ld bc, -100
	call Num1
	ld c, -10
	call Num1
	ld c, -1
Num1: ld a, '0'-1
Num2: inc a
	add hl,bc
	jr c,Num2
	sbc hl,bc
	rst RST_putc
	ret
