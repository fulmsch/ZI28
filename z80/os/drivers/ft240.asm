.list

; FT240x driver

ft240_fileDriver:
	.dw ft240_read
	.dw ft240_write
;	.dw 0 ;seek

.define FT240_DATA   0
.define FT240_STATUS 1

.func ft240_read:
;; Inputs: ix = file entry addr, (de) = buffer, bc = count
;; a = errno, de = count
;; Errors: 0=no error

	;calculate loop value in bc
	ld a, c
	dec bc
	inc b
	ld c, b
	ld b, a
	ld hl, 0

poll:
	in a, (FT240_STATUS)
	bit 1, a
	jr nz, poll
	in a, (FT240_DATA)
	ld (de), a
	inc de
	inc hl
	djnz poll
	dec c
	jr nz, poll
	ex de, hl
	ret
.endf ;ft240_read


.func ft240_write:
;; Inputs: ix = file entry addr, (de) = buffer, bc = count
;; a = errno, de = count
;; Errors: 0=no error

	;calculate loop value in bc
	ld a, c
	dec bc
	inc b
	ld c, b
	ld b, a

	ld hl, 0

poll:
	in a, (FT240_STATUS)
	bit 0, a
	jr nz, poll
	ld a, (de)
	out (FT240_DATA), a
	inc de
	inc hl
	djnz poll
	dec c
	jr nz, poll
	ex de, hl
	ret
.endf ;ft240_write
