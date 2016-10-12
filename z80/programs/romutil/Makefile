INCLUDEPATH = ../../includes

romutil.hex: romutil.asm $(INCLUDEPATH)/*.h
	z80asm -v -i romutil.asm -o romutil.obj -I $(INCLUDEPATH)
	srec_cat romutil.obj -binary -o romutil.hex -intel
