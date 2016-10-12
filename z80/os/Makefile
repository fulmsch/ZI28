INCLUDEPATH = ../../includes

all: cli/cli.hex bcos/bcos.hex

cli/cli.hex: cli/cli.asm cli/builtins.asm $(INCLUDEPATH)/*.h
	cd cli && z80asm -v -icli.asm -ocli.obj -Lcli.lbl -I $(INCLUDEPATH) && \
	srec_cat cli.obj -binary -o cli.hex -intel

bcos/bcos.hex: bcos/bcos.asm bcos/fat.asm $(INCLUDEPATH)/*.h
	cd bcos && z80asm -v -ibcos.asm -obcos.obj -Lbcos.lbl -I $(INCLUDEPATH) && \
	srec_cat bcos.obj -binary -o bcos.hex -intel
