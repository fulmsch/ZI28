SECTION rom_code
PUBLIC rshift32, rshift9_32

EXTERN rshiftbyte32

rshift9_32:
;; Shift a 32-bit number right by 9 bits
;;
;; Input:
;; : (hl) - 32-bit number
;;
;; Output:
;; : (hl) = (hl) >> 9
;;
;; Destroyed:
;; : none

	call rshiftbyte32

rshift32:
;; Shift a 32-bit number right by 1 bit
;;
;; Input:
;; : (hl) - 32-bit number
;;
;; Output:
;; : (hl) = (hl) >> 1
;; : carry flag
;;
;; Destroyed:
;; : none

	or a
	inc hl
	inc hl
	inc hl

	rr (hl)
	dec hl
	rr (hl)
	dec hl
	rr (hl)
	dec hl
	rr (hl)
	ret
