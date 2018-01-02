SECTION rom_code
PUBLIC memset

memset:
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
