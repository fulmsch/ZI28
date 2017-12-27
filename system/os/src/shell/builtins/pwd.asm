.list

.func b_pwd:
	ld a, (argc)
	cp 1
	jr nz, invalidCall

	ld hl, pathBuffer
	push hl
	call k_getcwd
	pop hl
	call printStr
	ld a, 0x0a
	jp RST_putc


invalidCall:
	ret
.endf
