SECTION rom_code
PUBLIC ld16

ld16:
;; Load a 16-bit number into a 32-bit pointer
;;
;; Input:
;; : de - 16-bit number
;; : hl - 32-bit pointer
;;
;; Output:
;; : (hl) = de
;;
;; Destroyed:
;; : none

	push hl

	ld (hl), e
	inc hl
	ld (hl), d
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), 0

	pop hl
	ret
