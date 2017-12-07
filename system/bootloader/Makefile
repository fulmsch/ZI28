include ../../config.mk

SRCDIR = src

SRCFILES = $(shell find $(SRCDIR)/ -type f -name '*.asm' -o -name '*.h') \
           $(SRCDIR)/gitversion.asm
INCLUDEFILES = $(shell find $(INCLUDEDIR)/ -type f -name '*.h')

.PHONY: all clean distclean sim

all: bootloader.bin bootloader.hex

clean distclean:
	@rm -f bootloader.bin bootloader.hex bootloader.lst $(SRCDIR)/gitversion.asm

romutil.bin: $(SRCDIR)/romutil.asm
	naken_asm -b $(SRCDIR)/romutil.asm -o romutil.bin -l -I $(INCLUDEDIR) -I $(SRCDIR)

bootloader.bin: romutil.bin $(SRCFILES) $(INCLUDEFILES)
	naken_asm -b $(SRCDIR)/main.asm -o bootloader.bin -l -I $(INCLUDEDIR) -I $(SRCDIR)

bootloader.hex: bootloader.bin
	objcopy -I binary -O ihex bootloader.bin bootloader.hex

sim: | bootloader.bin
	zi28sim -r bootloader.bin & sleep 0.5 && picocom /tmp/zi28sim --omap crcrlf,delbs --send-cmd "ascii-xfr -snvde" --receive-cmd "ascii-xfr -rne"

$(SRCDIR)/gitversion.asm: $(ROOTDIR)/.git/HEAD $(ROOTDIR)/.git/index
	echo -e "gitversion:\n\t.asciiz \"Commit: $(shell git describe --always --abbrev=10)\\nBuild: $(shell date -Iminutes)\"" > $@
