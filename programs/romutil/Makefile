INCLUDEPATH = ../../includes

romutil.hex: romutil.asm $(INCLUDEPATH)/*.h
	naken_asm -b romutil.asm -o romutil.obj -I $(INCLUDEPATH)
	srec_cat romutil.obj -binary -o romutil.hex -intel
