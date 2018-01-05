SECTION rom_code
INCLUDE "os.h"
PUBLIC getc, _getc

EXTERN k_read, bankRestore, bankOs

_getc:
;; Read a single character from stdin.
;;
;; Output:
;; : a - character

	push hl
	ld hl, bankRestore
	ex (sp), hl
	push af
	call bankOs
	pop af
getc:

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

SECTION bram_os
getc_buffer:
	DEFB 0
