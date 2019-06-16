include ../../config.mk

SRCDIR = src

ASMFILES = $(filter-out src/romutil.asm, $(shell find $(SRCDIR)/ -type f -name '*.asm'))
OBJFILES = $(ASMFILES:.asm=.o)

.PHONY: all clean distclean

all: bank0.bin bank0.hex

src/romutil.bin: $(SRCDIR)/romutil.asm
	z80asm -b -oromutil.bin -I$(INCLUDEDIR) $(SRCDIR)/romutil.asm

%.o: %.asm src/romutil.bin
	z80asm -o$@ -I$(INCLUDEDIR)/asm -Iinclude $<

bank0.bin: $(OBJFILES) src/bank0.lst src/romutil.bin
	z80asm -b -m -g -I$(INCLUDEDIR)/asm -Iinclude -o$@ @src/bank0.lst

bank0.hex: bank0.bin
	objcopy -I binary -O ihex bank0.bin bank0.hex


clean:
	@find $(SRCDIR) -iname "*.o" -delete
	@find $(SRCDIR) -iname "*.err" -delete
	@find $(SRCDIR) -iname "*.def" -delete
	@find $(SRCDIR) -iname "*.map" -delete

distclean: clean
	@$(RM) *.bin *.hex
