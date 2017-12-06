romutil.hex: romutil.asm
	naken_asm -b romutil.asm -o ROMUTIL.EX8
	cp ROMUTIL.EX8 ../../sysroot/BIN/ROMUTIL.EX8
	objcopy -I binary -O ihex ROMUTIL.EX8 romutil.hex
