.list

.func b_help:
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
	rst RST_putc
	push bc
	call printStr
	pop bc
	ld a, 0dh
	rst RST_putc
	ld a, 0ah
	rst RST_putc
	jr tableLoop

path:
;	ld hl, pathMsg
;	call printStr
;	;print the path
;	xor a
;	ld (cliProgramName), a
;	ld hl, programPath
;	call printStr

;	ld a, 0dh
;	rst RST_putc
;	ld a, 0ah
;	rst RST_putc

	ret

helpMsg:
	.asciiz: "The following commands are available:\n"
pathMsg:
	.asciiz: "\nAdditional programs will be searched in:\n "
.endf
