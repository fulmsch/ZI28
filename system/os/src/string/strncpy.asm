SECTION rom_code
PUBLIC strncpy

strncpy:
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
