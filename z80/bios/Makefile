INCLUDEPATH = ../includes

bios.hex: bios.asm io.asm interrupt.asm sd.asm monitor.asm bios_memmap.h iomap.h $(INCLUDEPATH)/*.h
	z80asm -v -i bios.asm -o bios.obj -I $(INCLUDEPATH)
	srec_cat bios.obj -binary -o bios.hex -intel
