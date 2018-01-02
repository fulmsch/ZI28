SECTION rom_code
PUBLIC strlen

strlen:
;; Returns the length of the string pointed to by hl
;;
;; Input:
;; : hl - string pointer
;;
;; Output:
;; : bc - length not including the null terminator
;;
;; Destroyed:
;; : hl

	ld bc, 0
loop:
	ld a, (hl)
	cp 0
	ret z
	inc bc
	inc hl
	jr loop
