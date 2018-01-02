SECTION rom_code
INCLUDE "os.h"
PUBLIC _getc

EXTERN k_read

_getc:
;; Read a single character from stdin.
;;
;; Output:
;; : a - character

IFNDEF DEBUG

	push bc
	push de
	push hl

	ld a, STDIN_FILENO
	ld de, getc_buffer
	ld hl, 1
	call k_read
	ld a, (getc_buffer)

	pop hl
	pop de
	pop bc
	ret

ELSE ;DEBUG

poll:
	in a, (1)
	bit 1, a
	jr nz, poll
	in a, (0)
	ret

ENDIF ;DEBUG

SECTION BSS
getc_buffer:
	DEFB 0
