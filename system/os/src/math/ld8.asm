SECTION rom_code
PUBLIC ld8

EXTERN clear32

ld8:
;; Load an 8-bit number into a 32-bit pointer
;;
;; Input:
;; : a - 8-bit number
;; : hl - 32-bit pointer
;;
;; Output:
;; : (hl) = a
;;
;; Destroyed:
;; : none

	;clear (hl)
	call clear32
	ld (hl), a
	ret
