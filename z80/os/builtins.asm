.func echo:
	;print all arguments
	ld a, (argc)
	dec a
	ret z
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
	call printStr
	ld a, ' '
	call putc
	djnz loop

	ld a, 0dh
	call putc
	ld a, 0ah
	call putc
	ret
.endf


.func help:
	ld hl, helpMsg
	call printStr
	;print commands from dispatch table
	ld bc, dispatchTable
tableLoop:
	ld a, (bc)
	ld l, a
	inc bc
	ld a, (bc)
	ld h, a
	inc bc
	inc bc
	inc bc
	ld a, (hl)
	cp 00h
	jr z, path
	ld a, ' '
	call putc
	call printStr
	ld a, 0dh
	call putc
	ld a, 0ah
	call putc
	jr tableLoop

path:
	ld hl, pathMsg
	call printStr
	;print the path
	xor a
	ld (cliProgramName), a
	ld hl, programPath
	call printStr

	ld a, 0dh
	call putc
	ld a, 0ah
	call putc

	ret

helpMsg:
	.asciiz: "The following commands are available:\r\n"
pathMsg:
	.asciiz: "\r\nAdditional programs will be searched in:\r\n "
.endf

.func exit:
	pop hl
	ret
.endf


.func cliMonitor:
	rst 38h
	ret
.endf
