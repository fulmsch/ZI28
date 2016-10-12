
INCLUDEPATH = ~/Dropbox/Projekte/Z80/Programme/Includes

mbr.hex: mbr.asm $(INCLUDEPATH)/*.h
	z80asm -v -i mbr.asm -o mbr.obj -I $(INCLUDEPATH)
	srec_cat mbr.obj -binary -o mbr.hex -intel

