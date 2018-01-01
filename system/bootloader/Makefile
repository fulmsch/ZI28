include ../../config.mk

SRCDIR = src

SRCFILES = $(shell find $(SRCDIR)/ -type f -name '*.asm' -o -name '*.h') \
           $(SRCDIR)/gitversion.asm
INCLUDEFILES = $(shell find $(INCLUDEDIR)/ -type f -name '*.h')

.PHONY: all clean distclean sim

all: bootloader.bin bootloader.hex

clean:
	@$(RM) romutil.bin bootloader.hex bootloader.lst $(SRCDIR)/gitversion.asm $(SRCDIR)/*.o

distclean: clean
	@$(RM) bootloader.bin

romutil.bin: $(SRCDIR)/romutil.asm
	z80asm -b -oromutil.bin -I$(INCLUDEDIR) $(SRCDIR)/romutil.asm

bootloader.bin: romutil.bin $(SRCFILES) $(INCLUDEFILES)
	z80asm -b -obootloader.bin -I$(INCLUDEDIR) $(SRCDIR)/main.asm

bootloader.hex: bootloader.bin
	objcopy -I binary -O ihex bootloader.bin bootloader.hex

run:
	$(ROOTDIR)/emulator/zi28emu -r bootloader.bin -c $(ROOTDIR)/user/sd.img& sleep 0.5 && picocom /tmp/zi28tty --omap crcrlf,delbs --send-cmd "ascii-xfr -snvde" --receive-cmd "ascii-xfr -rne"; killall zi28emu

$(SRCDIR)/gitversion.asm: $(ROOTDIR)/.git/HEAD $(ROOTDIR)/.git/index
	echo -e 'PUBLIC gitversion\ngitversion:\n\tDEFM "Commit: $(shell git describe --always --abbrev=10)\\nBuild: $(shell date -Iminutes)", 0x00' > $@
