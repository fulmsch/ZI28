SECTION rom_code
PUBLIC ld32

ld32:
;; Copy a 32-bit number from (hl) to (de)
;;
;; Input:
;; : (hl) - 32-bit number
;; : de - 32-bit pointer
;;
;; Destroyed:
;; : none

	push bc
	push de
	push hl

	ld bc, 4
	ldir

	pop hl
	pop de
	pop bc

	ret
