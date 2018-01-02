SECTION rom_code
PUBLIC clear32

clear32:
;; Sets a 32-bit number to 0
;;
;; Input:
;; : (hl) - 32-bit number
;;
;; Output:
;; : (hl) = 0
;;
;; Destroyed:
;; : none

	push hl
	push bc
	ld b, 4
loop:
	ld (hl), 0
	inc hl
	djnz loop

	pop bc
	pop hl
	ret
