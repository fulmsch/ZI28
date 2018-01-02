SECTION rom_code
PUBLIC strcat

EXTERN strcpy

strcat:
;; Appends hl to the end of de
;;
;; Input:
;; : de, hl - string pointers
;;
;; Destroyed:
;; : a, de, hl

	;Find the end of (de)
srcloop:
	ld a, (de)
	cp 0
	inc de
	jr nz, srcloop
	dec de

	;Copy hl to de
	jp strcpy
