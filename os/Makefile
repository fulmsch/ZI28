ROOTDIR = ..
UTILDIR = $(ROOTDIR)/utils
SRCDIR = src
INCLUDEDIR = $(ROOTDIR)/include

SRCFILES = $(shell find $(SRCDIR)/ -type f -name '*.asm' -o -name '*.h')
SRCFILES += $(SRCDIR)/gitversion.asm
INCLUDEFILES = $(shell find $(INCLUDEDIR)/ -type f -name '*.h')

.PHONY: all clean docs sim

all: os.obj os.hex

clean:
	rm os.obj os.hex os.lst $(SRCDIR)/gitversion.asm

os.obj: $(SRCFILES) $(INCLUDEFILES)
	naken_asm -b $(SRCDIR)/main.asm -o os.obj -l -I $(INCLUDEDIR) -I $(SRCDIR)

os.hex: os.obj
	srec_cat os.obj -binary -o os.hex -intel

sim:
	zi28sim -r os.obj & sleep 0.5 && picocom /tmp/zi28sim --omap crcrlf,delbs --send-cmd "ascii-xfr -snvde" --receive-cmd "ascii-xfr -rne"

$(SRCDIR)/gitversion.asm: $(ROOTDIR)/.git/HEAD $(ROOTDIR)/.git/index
	echo -e "gitversion:\n\t.asciiz \"Commit: $(shell git describe --always --abbrev=10)\\nBuild: $(shell date -Iminutes)\"" > $@
