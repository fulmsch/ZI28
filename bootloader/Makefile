ROOTDIR = ..
UTILDIR = $(ROOTDIR)/utils
SRCDIR = src
INCLUDEDIR = $(ROOTDIR)/include

SRCFILES = $(shell find $(SRCDIR)/ -type f -name '*.asm' -o -name '*.h')
SRCFILES += $(SRCDIR)/gitversion.asm
INCLUDEFILES = $(shell find $(INCLUDEDIR)/ -type f -name '*.h')

.PHONY: all clean docs sim

all: bootloader.bin bootloader.hex

clean:
	-rm bootloader.bin bootloader.hex bootloader.lst $(SRCDIR)/gitversion.asm

bootloader.bin: $(SRCFILES) $(INCLUDEFILES)
	naken_asm -b $(SRCDIR)/main.asm -o bootloader.bin -l -I $(INCLUDEDIR) -I $(SRCDIR)

bootloader.hex: bootloader.bin
	srec_cat bootloader.bin -binary -o bootloader.hex -intel

sim:
	zi28sim -r bootloader.bin & sleep 0.5 && picocom /tmp/zi28sim --omap crcrlf,delbs --send-cmd "ascii-xfr -snvde" --receive-cmd "ascii-xfr -rne"

$(SRCDIR)/gitversion.asm: $(ROOTDIR)/.git/HEAD $(ROOTDIR)/.git/index
	echo -e "gitversion:\n\t.asciiz \"Commit: $(shell git describe --always --abbrev=10)\\nBuild: $(shell date -Iminutes)\"" > $@
