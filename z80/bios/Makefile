INCLUDEPATH = ../../includes

bios.hex: bios.asm io.asm interrupt.asm sd.asm monitor.asm bios_memmap.h iomap.h $(INCLUDEPATH)/*.h
	z80asm -v -ibios.asm -obios.obj -lbios.lst -Lbios.lbl -I $(INCLUDEPATH)
	srec_cat bios.obj -binary -o bios.hex -intel
