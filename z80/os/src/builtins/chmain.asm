.list

.func b_chmain:
	ld a, (argc)
	cp 2
	jr nz, invalidCall

	ld hl, argv
	inc hl
	inc hl

	ld e, (hl)
	inc hl
	ld d, (hl)
	;(de) = drive name

	jp k_chmain

invalidCall:
	ret
.endf
