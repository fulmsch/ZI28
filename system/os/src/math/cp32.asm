SECTION rom_code
PUBLIC cp32

cp32:
;; Compares two 32-bit numbers
;;
;; Input:
;; : (hl), (de) - 32-bit numbers
;;
;; Output:
;; : c  - (hl) >  (de)
;; : nc - (hl) <= (de)
;; : z  - (hl) == (de)
;; : nz - (hl) != (de)
;;
;; Destroyed:
;; : a, b, de, hl

;move the pointers to the msb
	ld b, 3
startLoop:
	inc hl
	inc de
	djnz startLoop

	ld b, 4
loop:
	ld a, (de)
	cp (hl)
	ret nz
	dec hl
	dec de
	djnz loop
	ret
