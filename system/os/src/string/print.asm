SECTION rom_code
INCLUDE "os.h"

PUBLIC print

EXTERN k_write, strlen

print:
;; Print a zero-terminated string to stdout.
;;
;; Input:
;; : (hl) - string

IFNDEF DEBUG

	push hl
	call strlen
	ld h, b
	ld l, c
	pop de
	ld a, STDOUT_FILENO
	jp k_write

ELSE ;DEBUG

	ld a, (hl)
	cp 0x00
	ret z
	rst RST_putc
	inc hl
	jr print

ENDIF ;DEBUG
