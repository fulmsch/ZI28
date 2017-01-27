INCLUDEPATH = ../includes

all: os.hex

os.hex: *.h *.asm */*.asm $(INCLUDEPATH)/*.h
	naken_asm -b os.asm -o os.obj -l -I $(INCLUDEPATH) && \
	srec_cat os.obj -binary -o os.hex -intel
