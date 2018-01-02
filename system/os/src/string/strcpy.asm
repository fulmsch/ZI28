SECTION rom_code
PUBLIC strcpy

strcpy:
;; Copy a string from hl to de
;;
;; Input:
;; : de, hl - string pointers
;;
;; Destroyed:
;; : a, de, hl

	ld a, (hl)
	ld (de), a
	cp 0x00
	ret z
	inc hl
	inc de
	jr strcpy
