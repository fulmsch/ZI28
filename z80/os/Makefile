INCLUDEPATH = ../includes

all: cli/cli.hex bcos/bcos.hex

cli/cli.hex: cli/cli.asm cli/builtins.asm $(INCLUDEPATH)/*.h
	cd cli && z80asm -v -i cli.asm -o cli.obj -I ../$(INCLUDEPATH) && \
	srec_cat cli.obj -binary -o cli.hex -intel

bcos/bcos.hex: bcos/bcos.asm bcos/fat.asm bcos/file.asm $(INCLUDEPATH)/*.h
	cd bcos && z80asm -v -i bcos.asm -o bcos.obj -lbcos.lst -I ../$(INCLUDEPATH) && \
	srec_cat bcos.obj -binary -o bcos.hex -intel
