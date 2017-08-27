
	SECTION	code_clib
          PUBLIC  fputc_cons_native


;
; Entry:        a= char to print
;


.fputc_cons_native
	rst 0x0008
	ret
