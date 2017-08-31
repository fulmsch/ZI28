romutil.hex: romutil.asm
	naken_asm -b romutil.asm -o romutil.obj
	srec_cat romutil.obj -binary -o romutil.hex -intel
