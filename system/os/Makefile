include ../../Make.config

SRCDIR = src

SRCFILES = $(shell find $(SRCDIR)/ -type f -name '*.asm' -o -name '*.h') \
           $(SRCDIR)/gitversion.asm
INCLUDEFILES = $(shell find $(INCLUDEDIR)/ -type f -name '*.h')

.PHONY: all clean distclean sim

all: os.bin os.hex

clean distclean:
	@rm -f os.bin os.hex os.lst $(SRCDIR)/gitversion.asm

os.bin: $(SRCFILES) $(INCLUDEFILES)
	naken_asm -b $(SRCDIR)/main.asm -o os.bin -l -I $(INCLUDEDIR) -I $(SRCDIR)

os.hex: os.bin
	srec_cat os.bin -binary -o os.hex -intel

sim: | os.bin
	zi28sim -r os.bin & sleep 0.5 && picocom /tmp/zi28sim --omap crcrlf,delbs --send-cmd "ascii-xfr -snvde" --receive-cmd "ascii-xfr -rne"

$(SRCDIR)/gitversion.asm: $(ROOTDIR)/.git/HEAD $(ROOTDIR)/.git/index
	echo -e "gitversion:\n\t.asciiz \"Commit: $(shell git describe --always --abbrev=10)\\nBuild: $(shell date -Iminutes)\"" > $@
