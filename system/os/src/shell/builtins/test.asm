.list


.func b_test:
	ld a, (argc)
	cp 2
	ret nz

	ld hl, argv
	inc hl
	inc hl

	ld e, (hl)
	inc hl
	ld d, (hl)
	;(de) = path name
	jp k_unlink
.endf
