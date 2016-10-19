INCLUDEPATH = ../../includes

all: mbr.hex vbr.hex

mbr.hex: mbr.asm $(INCLUDEPATH)/*.h
	z80asm -v -i mbr.asm -o mbr.obj -lmbr.lst -I $(INCLUDEPATH)
	srec_cat mbr.obj -binary -o mbr.hex -intel

vbr.hex: vbr.asm $(INCLUDEPATH)/*.h
	z80asm -v -i vbr.asm -o vbr.obj -lvbr.lst -I $(INCLUDEPATH)
	srec_cat vbr.obj -binary -o vbr.hex -intel
