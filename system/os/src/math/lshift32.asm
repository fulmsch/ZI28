SECTION rom_code
PUBLIC lshift32, lshift9_32

EXTERN lshiftbyte32

lshift9_32:
;; Shift a 32-bit number left by 9 bits
;;
;; Input:
;; : (hl) - 32-bit number
;;
;; Output:
;; : (hl) = (hl) << 9
;;
;; Destroyed:
;; : none

	call lshiftbyte32

lshift32:
;; Shift a 32-bit number left by 1 bit
;;
;; Input:
;; : (hl) - 32-bit number
;;
;; Output:
;; : (hl) = (hl) << 1
;; : carry flag
;;
;; Destroyed:
;; : none

	push hl

	or a
	rl (hl)
	inc hl
	rl (hl)
	inc hl
	rl (hl)
	inc hl
	rl (hl)

	pop hl
	ret
