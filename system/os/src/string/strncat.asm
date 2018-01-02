SECTION rom_code
PUBLIC strncat

EXTERN strncpy

strncat:
;; Appends up to b characters from hl to the end of de
;;
;; Input:
;; : de, hl - string pointers
;;
;; Destroyed:
;; : a, b, de, hl

	;Find the end of (de)
srcloop:
	ld a, (de)
	cp 0
	inc de
	jr nz, srcloop
	dec de

	jp strncpy
