include ../../config.mk

SRCDIR = src
OBJDIR = obj

ASMFILES = $(shell find $(SRCDIR)/ -type f -name '*.asm') \
           $(SRCDIR)/version.asm
OBJFILES = $(ASMFILES:.asm=.o)

.PHONY: all clean distclean $(SRCDIR)/version.asm

all: os.bin os.hex

$(SRCDIR)/version.asm:
	@echo 'SECTION rom_data' > $@
	@echo 'PUBLIC version' >> $@
	@echo 'version:' >> $@
	@echo 'DEFM "Commit: $(shell git describe --always --abbrev=10)", 0x0a, "Build: $(shell date -Iminutes)", 0x00' >> $@

%.o: %.asm
	z80asm -o$@ -I$(INCLUDEDIR)/asm -Iinclude $<

os.bin: $(OBJFILES) src/os.lst
	z80asm -b -m -g -I$(INCLUDEDIR)/asm -Iinclude -o$@ @src/os.lst
	#$(ZCC) +zi28 --no-crt -Ca-I/home/florian/Dropbox/Projekte/ZI28/system/os/include -Ca-I/home/florian/Dropbox/Projekte/ZI28/include/asm @os.lst -oos.bin

os.hex: os.bin
	objcopy -I binary -O ihex os.bin os.hex


clean:
	@$(RM) $(SRCDIR)/version.asm
	@find $(SRCDIR) -iname "*.o" -delete
	@find $(SRCDIR) -iname "*.err" -delete

distclean: clean
	@$(RM) *.bin os.hex
