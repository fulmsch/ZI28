include ../../../config.mk

PKGNAME = VGATESTC
BINDIR = $(BUILDDIR)/BIN

BUILDDIR = build

TARGET = VGATESTC.EX8
HEXFILE = $(TARGET:.EX8=.hex)
PKGFILE = $(addsuffix .TZ7, $(PKGNAME))
CFILES = $(shell find . -iname "*.c")
HFILES = $(shell find . -iname "*.h")
CCFLAGS = #-m -g -s

.PHONY: all install clean distclean

all: $(TARGET) $(PKGFILE)

$(TARGET): $(CFILES) $(HFILES)
	$(ZCC) +zi28 $(CCFLAGS) $(CFILES) -o $(TARGET) -Iinclude
	objcopy -I binary -O ihex $(TARGET) $(HEXFILE)

$(PKGFILE): $(TARGET)
	mkdir -p $(BINDIR)
	cp $(TARGET) $(BINDIR)
	$(UTILDIR)/makepkg.sh $(BUILDDIR) $(PKGNAME)

install: $(PKGFILE)
	$(UTILDIR)/installpkg.sh $(PKGNAME) $(SYSROOT)

clean:
	$(RM) *.def *.map *.o* *.sym *.lst *.bin
	$(RM) -r $(BINDIR)

distclean: clean
	$(RM) $(TARGET) $(HEXFILE) $(PKGFILE)
