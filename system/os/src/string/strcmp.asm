SECTION rom_code
PUBLIC strcmp

strcmp:
;; Compares hl and de
;;
;; Input:
;; : de, hl - string pointers
;;
;; Output:
;; : z if equal strings
;;
;; Destroyed: a, b, de, hl

	ld a, (de)
	ld b, a
	ld a, (hl)
	cp b
	ret nz
	cp 0x00
	ret z
	inc de
	inc hl
	jr strcmp
