ROOTDIR = ../..
UTILDIR = $(ROOTDIR)/util
SRCDIR = src
INCLUDEDIR = ../includes

.PHONY: all clean docs

all: os.hex

clean:
	rm os.obj os.hex os.lst

os.hex: $(SRCDIR)/*.h $(SRCDIR)/*.asm $(SRCDIR)/*/*.asm $(INCLUDEDIR)/*.h
	#Assembly
	naken_asm -b src/os.asm -o os.obj -l -I $(INCLUDEDIR) -I src
	#Generate a hex file
	srec_cat os.obj -binary -o os.hex -intel
