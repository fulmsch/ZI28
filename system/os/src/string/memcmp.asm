SECTION rom_code
PUBLIC memcmp

memcmp:
;; Compares b bytes of hl and de
;;
;; Input:
;; : de, hl - pointers
;;
;; Output:
;; : z if equal
;;
;; Destroyed:
;; : a, bc, de, hl

	ld a, (de)
	ld c, a
	ld a, (hl)
	cp c
	ret nz
	inc de
	inc hl
	djnz memcmp
	ret
