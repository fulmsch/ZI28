ROOTDIR = ..
UTILDIR = $(ROOTDIR)/utils
SRCDIR = src
INCLUDEDIR = $(ROOTDIR)/include

.PHONY: all clean docs sim

all: os.hex

clean:
	rm os.obj os.hex os.lst

os.hex: $(SRCDIR)/*.h $(SRCDIR)/*.asm $(SRCDIR)/*/*.asm $(INCLUDEDIR)/*.h
	#Assembly
	naken_asm -b src/os.asm -o os.obj -l -I $(INCLUDEDIR) -I src
	#Generate a hex file
	srec_cat os.obj -binary -o os.hex -intel

sim:
	zi28sim -r os.obj & sleep 0.5 && picocom /tmp/zi28sim --omap delbs --send-cmd "ascii-xfr -snv" --receive-cmd "ascii-xfr -rne"
