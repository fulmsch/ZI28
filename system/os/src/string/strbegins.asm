SECTION rom_code
PUBLIC strbegins

strbegins:
;; Check if hl begins with de.
;;
;; Input:
;; : de, hl - string pointers
;;
;; Output:
;; : z if hl begins with de
;;
;; Destroyed: a, de, hl

	ld a, (de)
	cp 0x00
	ret z
	cp (hl)
	ret nz
	inc de
	inc hl
	jr strbegins
