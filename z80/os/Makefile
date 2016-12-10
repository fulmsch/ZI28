INCLUDEPATH = ../includes

all: cli/cli.hex bcos/bcos.hex

cli/cli.hex: cli/cli.asm cli/builtins.asm $(INCLUDEPATH)/*.h
	cd cli && naken_asm cli.asm -o cli.hex -l -I ../$(INCLUDEPATH) && \
	srec_cat cli.hex -intel -o cli.obj -binary && \
	cp cli.obj CLI.BIN

bcos/bcos.hex: bcos/bcos.asm bcos/fat.asm bcos/file.asm $(INCLUDEPATH)/*.h
	cd bcos && naken_asm bcos.asm -o bcos.hex -l -I ../$(INCLUDEPATH) && \
	srec_cat bcos.hex -intel -o bcos.obj -binary && \
	cp bcos.obj BCOS.BIN
