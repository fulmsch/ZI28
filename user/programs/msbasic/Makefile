include ../../../config.mk

PKGNAME = MSBASIC
BINDIR = $(BUILDDIR)/BIN

BUILDDIR = build

TARGET = $(addsuffix .EX8, $(PKGNAME))
HEXFILE = $(TARGET:.EX8=.hex)
PKGFILE = $(addsuffix .TZ7, $(PKGNAME))

.PHONY: all install clean distclean

all: $(TARGET) $(PKGFILE)

$(TARGET): basic.asm
	z80asm -b --output=$(TARGET) -I$(INCLUDEDIR) basic.asm
	objcopy -I binary -O ihex $(TARGET) $(HEXFILE)

$(PKGFILE): $(TARGET)
	mkdir -p $(BINDIR)
	cp $(TARGET) $(BINDIR)
	$(UTILDIR)/makepkg.sh $(BUILDDIR) $(PKGNAME)

install: $(PKGFILE)
	$(UTILDIR)/installpkg.sh $(PKGNAME) $(SYSROOT)

clean:
	$(RM) *.def *.map *.o* *.sym *.lst
	$(RM) -r build

distclean: clean
	$(RM) $(TARGET) $(HEXFILE) $(PKGFILE)
