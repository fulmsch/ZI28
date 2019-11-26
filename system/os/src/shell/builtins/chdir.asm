#code ROM

b_chdir:
#local
	ld a, (argc)
	cp 2
	jr nz, invalidCall

	ld hl, argv
	inc hl
	inc hl

	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
	;(hl) = path name

	jp k_chdir

invalidCall:
	ret
#endlocal
