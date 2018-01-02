SECTION rom_code
PUBLIC add32, adc32

add32:
;; Add two 32-bit numbers
;;
;; Input:
;; : (hl), (de) - 32-bit numbers
;;
;; Output:
;; : (hl) = (hl) + (de)
;;
;; Destroyed:
;; : none

	;clear the carry flag
	or a

adc32:
;; Add two 32-bit numbers and the carry bit
;;
;; Input:
;; : (hl), (de) - 32-bit numbers
;;
;; Output:
;; : (hl) = (hl) + (de) + cf
;;
;; Destroyed:
;; : none

	push af
	push bc
	push de
	push hl

	ld b, 4
loop:
	ld a, (de)
	adc a, (hl)
	ld (hl), a
	inc hl
	inc de
	djnz loop

	pop hl
	pop de
	pop bc
	pop af

	ret
