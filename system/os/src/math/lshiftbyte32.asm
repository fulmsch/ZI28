SECTION rom_code
PUBLIC lshiftbyte32

lshiftbyte32:
;; Shift a 32-bit number left by 1 byte
;;
;; Input:
;; : (hl) - 32-bit number
;;
;; Output:
;; : (hl) = (hl) << 8
;;
;; Destroyed:
;; : none

	push af
	push hl

	inc hl
	inc hl

	ld a, (hl)
	inc hl
	ld (hl), a
	dec hl
	dec hl

	ld a, (hl)
	inc hl
	ld (hl), a
	dec hl
	dec hl

	ld a, (hl)
	inc hl
	ld (hl), a
	dec hl
	ld (hl), 0

	pop hl
	pop af
	ret
