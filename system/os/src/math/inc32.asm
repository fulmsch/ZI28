SECTION rom_code
PUBLIC inc32

inc32:
;; Increment a 32-bit number by 1
;;
;; Input:
;; : (hl) - 32-bit number
;;
;; Output:
;; : (hl) = (hl) + 1
;;
;; Destroyed:
;; : none

	push hl

	inc (hl)
	jr nz, exit
	inc hl
	
	inc (hl)
	jr nz, exit
	inc hl

	inc (hl)
	jr nz, exit
	inc hl

	inc (hl)

exit:
	pop hl
	ret
