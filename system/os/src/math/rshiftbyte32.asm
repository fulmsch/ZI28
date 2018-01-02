SECTION rom_code
PUBLIC rshiftbyte32

rshiftbyte32:
;; Shift a 32-bit number right by 1 byte
;;
;; Input:
;; : (hl) - 32-bit number
;;
;; Output:
;; : (hl) = (hl) >> 8
;;
;; Destroyed:
;; : none

	push af
	push hl

	inc hl
	ld a, (hl)
	dec hl
	ld (hl), a
	inc hl

	inc hl
	ld a, (hl)
	dec hl
	ld (hl), a
	inc hl

	inc hl
	ld a, (hl)
	dec hl
	ld (hl), a
	inc hl

	ld (hl), 0

	pop hl
	pop af
	ret
