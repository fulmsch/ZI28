SECTION rom_code
PUBLIC strtup

EXTERN toupper

strtup:
;; Converts a string to uppercase
;;
;; Input:
;; : hl - string pointer
;;
;; Destroyed:
;; : a, hl

	ld a, (hl)
	cp 0
	ret z

	call toupper
	ld (hl), a
	inc hl
	jr strtup
