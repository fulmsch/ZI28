SECTION rom_code
PUBLIC strncmp

strncmp:
;; Compares at most the first b characters of hl and de
;;
;; Input:
;; : de, hl - string pointers
;; : b - length
;;
;; Output:
;; : z if equal strings
;;
;; Destroyed:
;; : a, bc, de, hl

	ld a, (de)
	ld c, a
	ld a, (hl)
	cp c
	ret nz
	cp 0
	ret z
	inc de
	inc hl
	djnz strncmp
	ret
