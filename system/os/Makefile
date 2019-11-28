include ../../config.mk

SRCDIR = src

ORGFILES = $(shell find $(SRCDIR)/ -type f -name '*.org')

ASMFILES = $(shell find $(SRCDIR)/ -type f -name '*.asm') \
           $(ORGFILES:.org=.asm) \
           $(SRCDIR)/version.asm

.PHONY: all clean distclean $(SRCDIR)/version.asm

all: os.bin os.hex

$(SRCDIR)/version.asm:
	@echo '#code ROM' > $@
	@echo 'version:' >> $@
	@echo '.ascii "Commit: $(shell git describe --always --abbrev=10)",0x0a,"Build: $(shell date -Iminutes)",0x00' >> $@

%.asm: %.org
	@emacs --batch -l org --eval="(setq org-src-preserve-indentation t)" $< -f org-babel-tangle

os.bin: $(ASMFILES)
	zasm -uw -i src/main.asm -o os.bin -l os.lst

os.hex: os.bin
	objcopy -I binary -O ihex os.bin os.hex


clean:
	@find $(SRCDIR) -iname "*.asm" -delete

distclean: clean
	@$(RM) os.bin os.hex os.lst
