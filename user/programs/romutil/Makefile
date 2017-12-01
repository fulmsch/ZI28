romutil.hex: romutil.asm
	naken_asm -b romutil.asm -o ROMUTIL.EX8
	cp ROMUTIL.EX8 ../../sysroot/BIN/ROMUTIL.EX8
	srec_cat ROMUTIL.EX8 -binary -o romutil.hex -intel
