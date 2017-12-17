include ../../../config.mk

PKGNAME = TICTACTO

TARGET = $(addsuffix .EX8, $(PKGNAME))
HEXFILE = $(TARGET:.EX8=.hex)
PKGFILE = $(addsuffix .TZ7, $(PKGNAME))
CFILES = $(shell find . -iname "*.c")
HFILES = $(shell find . -iname "*.h")
CCFLAGS = #-m -g -s

.PHONY: all install clean distclean

all: $(TARGET) $(PKGFILE)

$(TARGET): $(CFILES) $(HFILES)
	zcc +zi28 $(CCFLAGS) $(CFILES) -o $(TARGET) -Iinclude
	objcopy -I binary -O ihex $(TARGET) $(HEXFILE)

$(PKGFILE): $(TARGET)
	mkdir -p build build/GAMES
	cp $(TARGET) build/GAMES
	$(UTILDIR)/makepkg.sh build $(PKGNAME)

install: $(PKGFILE)
	$(UTILDIR)/installpkg.sh $(PKGNAME) $(SYSROOT)

clean:
	$(RM) *.def *.map *.o* *.sym *.lst
	$(RM) -r build

distclean: clean
	$(RM) $(TARGET) $(HEXFILE) $(PKGFILE)
