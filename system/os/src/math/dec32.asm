SECTION rom_code
PUBLIC dec32

dec32:
;; Decrement a 32-bit number by 1
;;
;; Input:
;; : (hl) - 32-bit number
;;
;; Output:
;; : (hl) = (hl) - 1
;;
;; Destroyed:
;; : none

	push hl

	dec (hl)
	jp p, exit
	inc hl

	dec (hl)
	jp p, exit
	inc hl

	dec (hl)
	jp p, exit
	inc hl

	dec (hl)

exit:
	pop hl
	ret
