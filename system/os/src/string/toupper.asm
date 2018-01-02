SECTION rom_code
PUBLIC toupper

toupper:
;; Converts a character to uppercase
;;
;; Input:
;; : a - char

	cp 0x61
	ret c
	cp 0x7b
	ret nc
	sub 0x20
	ret
