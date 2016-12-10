INCLUDEPATH = ../../includes

romutil.hex: romutil.asm $(INCLUDEPATH)/*.h
	naken_asm romutil.asm -o romutil.hex -I $(INCLUDEPATH)
	srec_cat romutil.hex -intel -o romutil.obj -binary
