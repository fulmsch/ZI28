SECTION rom_code
INCLUDE "os.h"

PUBLIC _putc

EXTERN k_write

_putc:
;; Print a single character to stdout.
;;
;; Input:
;; : a - character

IFNDEF DEBUG

	push af
	push bc
	push de
	push hl

	ld de, putc_buffer
	ld (de), a
	ld hl, 1
	ld a, STDOUT_FILENO
	call k_write

	pop hl
	pop de
	pop bc
	pop af
	ret

ELSE ;DEBUG

	push af
poll:
	in a, (1)
	bit 0, a
	jr nz, poll
	pop af
	out (0), a
	ret

ENDIF ;DEBUG

SECTION BSS
putc_buffer:
	DEFB 0
