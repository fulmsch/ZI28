INCLUDEPATH = ../includes

bios.hex: bios.asm io.asm interrupt.asm sd.asm monitor.asm bios_memmap.h iomap.h $(INCLUDEPATH)/*.h
	naken_asm bios.asm -o bios.hex -I $(INCLUDEPATH)
	srec_cat bios.hex -intel -o bios.obj -binary
