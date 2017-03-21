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
	cd $(SRCDIR) && \
	naken_asm -b os.asm -o ../os.obj -l -I ../$(INCLUDEDIR)
	#Generate a hex file
	srec_cat os.obj -binary -o os.hex -intel
