include ../../../config.mk

PKGNAME = GUESS
BINDIR = $(BUILDDIR)/GAMES

BUILDDIR = build

TARGET = $(addsuffix .EX8, $(PKGNAME))
HEXFILE = $(TARGET:.EX8=.hex)
PKGFILE = $(addsuffix .TZ7, $(PKGNAME))

.PHONY: all install clean distclean

all: $(TARGET) $(PKGFILE)

$(TARGET): guessing_game.asm
	naken_asm -b guessing_game.asm -o $(TARGET) -I$(INCLUDEDIR)
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
