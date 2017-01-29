; FT240x driver
; TODO allow more than 256 bytes read/write

ft240_fileDriver:
	.dw ft240_read
	.dw ft240_write
	.dw 0 ;seek


.func ft240_read:
;; Inputs: ix = file entry addr, (de) = buffer, b = count
;; a = errno, de = count
;; Errors: 0=no error

	ld hl, 0

poll:
	in a, (TERMCR)
	bit 1, a
	jr nz, poll
	in a, (TERMDR)
	ld (de), a
	inc de
	inc hl
	djnz poll
	ex de, hl
	ret
.endf ;ft240_read


.func ft240_write:
;; Inputs: ix = file entry addr, (de) = buffer, b = count
;; a = errno, de = count
;; Errors: 0=no error

	ld hl, 0

poll:
	in a, (TERMCR)
	bit 0, a
	jp nz, poll
	ld a, (de)
	out (TERMDR), a
	inc de
	inc hl
	djnz poll
	ex de, hl
	ret
.endf ;ft240_write
