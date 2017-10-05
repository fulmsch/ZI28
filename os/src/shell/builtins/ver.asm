.list

.func b_ver:
	ld a, (argc)
	cp 1
	jr nz, invalidCall

	ld hl, gitversion
	call printStr
	ld a, 0x0a
	jp putc

invalidCall:
	ret
.endf
