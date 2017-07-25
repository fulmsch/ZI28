
		SECTION	code_clib
		PUBLIC	fgetc_cons
		PUBLIC	_fgetc_cons

.fgetc_cons
._fgetc_cons
	rst 0x0010
	ld	l,a
	ld	h,0
	ret
