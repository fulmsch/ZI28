echo:
	;print all arguments
	ld a, (argc)
	dec a
	ret z
	ld b, a
	ld de, argv
	inc de
	inc de

.echoLoop:
	ld a, (de)
	ld l, a
	inc de
	ld a, (de)
	ld h, a
	inc de
	call printStr
	ld a, ' '
	call putc
	djnz .echoLoop

	ld a, 0dh
	call putc
	ld a, 0ah
	call putc
	ret


exit:
	pop hl
	ret


cliMonitor:
	rst 38h
	ret
