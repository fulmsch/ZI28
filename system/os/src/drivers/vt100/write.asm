SECTION rom_code
INCLUDE "drivers/vt100.h"

PUBLIC vt100_write

vt100_write:
;; Write to the USB-connection on the mainboard
;;
;; Input:
;; : ix - file entry addr
;; : (de) - buffer
;; : bc - count
;;
;; Output:
;; : de - count
;; : a - errno
; Errors: 0=no error

	;calculate loop value in bc
	ld a, c
	dec bc
	inc b
	ld c, b
	ld b, a

	ld hl, 0

poll:
	ld a, (de)
	;print a
	inc de
	inc hl
	djnz poll
	dec c
	jr nz, poll
	ex de, hl
	ret
