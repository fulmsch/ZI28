INCLUDEPATH = ../../includes

all: mbr.hex vbr.hex

mbr.hex: mbr.asm $(INCLUDEPATH)/*.h
	naken_asm mbr.asm -o mbr.hex -l -I $(INCLUDEPATH)
	srec_cat mbr.hex -intel -o mbr.obj -binary

vbr.hex: vbr.asm $(INCLUDEPATH)/*.h
	naken_asm vbr.asm -o vbr.hex -l -I $(INCLUDEPATH)
	srec_cat vbr.hex -intel -o vbr.obj -binary
