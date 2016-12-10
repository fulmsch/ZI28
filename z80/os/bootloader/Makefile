INCLUDEPATH = ../../includes

all: mbr.hex vbr.hex

mbr.hex: mbr.asm $(INCLUDEPATH)/*.h
	naken_asm -b mbr.asm -o mbr.obj -l -I $(INCLUDEPATH)
	srec_cat mbr.obj -binary -o mbr.hex -intel

vbr.hex: vbr.asm $(INCLUDEPATH)/*.h
	naken_asm -b vbr.asm -o vbr.obj -l -I $(INCLUDEPATH)
	srec_cat vbr.obj -binary -o vbr.hex -intel
