include ../../config.mk

SRCDIR = src

ASMFILES = $(shell find $(SRCDIR)/ -type f -name '*.asm') \
           $(SRCDIR)/version.asm

.PHONY: all clean distclean $(SRCDIR)/version.asm

all: os.bin os.hex

$(SRCDIR)/version.asm:
	@echo 'version:' >> $@
	@echo 'db "Commit: $(shell git describe --always --abbrev=10)", 0x0a, "Build: $(shell date -Iminutes)", 0x00' >> $@

os.bin: $(ASMFILES)
	zasm -uw $(SRCDIR)/main.asm -o os.bin -l os.lst

os.hex: os.bin
	objcopy -I binary -O ihex os.bin os.hex


clean:
	@$(RM) $(SRCDIR)/version.asm
	@$(RM) os.lst

distclean: clean
	@$(RM) *.bin os.hex
