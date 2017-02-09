.list

.func b_echo:
	;print all arguments
	ld a, (argc)
	dec a
	jr z, newline
	ld b, a
	ld de, argv
	inc de
	inc de

loop:
	ld a, (de)
	ld l, a
	inc de
	ld a, (de)
	ld h, a
	inc de
	push de
	push bc
	call printStr
	pop bc
	pop de
	ld a, ' '
	call putc
	djnz loop

newline:
	ld a, 0dh
	call putc
	ld a, 0ah
	call putc
	ret
.endf
