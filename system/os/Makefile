include ../../config.mk

SRCDIR = src

ASMFILES = $(shell find $(SRCDIR)/ -type f -name '*.asm') \
           $(SRCDIR)/version.asm

.PHONY: all clean distclean $(SRCDIR)/version.asm

all: os.bin os.hex

$(SRCDIR)/version.asm:
	@echo '#code ROM' > $@
	@echo 'version:' >> $@
	@echo '.asciz "Commit: $(shell git describe --always --abbrev=10)\nBuild: $(shell date -Iminutes)"' >> $@
#	@echo 'DEFM "Commit: $(shell git describe --always --abbrev=10)", 0x0a, "Build: $(shell date -Iminutes)", 0x00' >> $@

#%.o: %.asm
#	z80asm -l -o$@ -I$(INCLUDEDIR)/asm -Iinclude $<

os.bin: $(ASMFILES)
	zasm -uw -i src/main.asm -o os.bin -l os.lst
#	z80asm -b -m -g -l -I$(INCLUDEDIR)/asm -Iinclude -o$@ @src/os.lst
#	$(ZCC) +zi28 --no-crt -Ca-I/home/florian/Dropbox/Projekte/ZI28/system/os/include -Ca-I/home/florian/Dropbox/Projekte/ZI28/include/asm @os.lst -oos.bin

os.hex: os.bin
	objcopy -I binary -O ihex os.bin os.hex


clean:
	@$(RM) $(SRCDIR)/version.asm
	@find $(SRCDIR) -iname "*.o" -delete
	@find $(SRCDIR) -iname "*.err" -delete

distclean: clean
	@$(RM) os.bin os.hex os.lst
