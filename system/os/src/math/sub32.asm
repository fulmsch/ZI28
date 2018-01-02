SECTION rom_code
PUBLIC sub32, sbc32

sub32:
;; Subtract two 32-bit numbers
;;
;; Input:
;; : (hl), (de) - 32-bit numbers
;;
;; Output:
;; : (de) = (de) - (hl)
;;
;; Destroyed:
;; : none

	;clear the carry flag
	or a

sbc32:
;; Subtract two 32-bit numbers and the carry bit
;;
;; Input:
;; : (hl), (de) - 32-bit numbers
;;
;; Output:
;; : (de) = (de) - (hl) - cf
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
	sbc a, (hl)
	ld (de), a
	inc de
	inc hl
	djnz loop

	pop hl
	pop de
	pop bc
	pop af

	ret
