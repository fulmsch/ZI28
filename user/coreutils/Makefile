include ../../config.mk

PKGNAME = COREUTIL

BUILDDIR = build
BINDIR = $(BUILDDIR)/BIN

CFILES = $(shell find src -iname "*.c")

TARGETS = $(notdir $(CFILES:.c=.ex8))

HEXFILES = $(notdir $(CFILES:.c=.hex))

PKGFILE = $(addsuffix .TZ7, $(PKGNAME))
HFILES = $(shell find . -iname "*.h")
CCFLAGS = #-m -g -s

.PHONY: all install clean distclean

all: $(PKGFILE) $(HEXFILES)

%.ex8: src/%.c $(HFILES)
	$(ZCC) +zi28 $(CCFLAGS) $< -o $@ -Iinclude

%.hex: %.ex8
	objcopy -I binary -O ihex $< $@

$(PKGFILE): $(TARGETS)
	@echo '--- Building package ---'
	@mkdir -p $(BINDIR)
	@for FILE in $(TARGETS); do \
		cp "$$FILE" "$(BINDIR)/$$(echo $$FILE | tr "[:lower:]" "[:upper:]")"; \
	done
	@$(UTILDIR)/makepkg.sh $(BUILDDIR) $(PKGNAME)

install: $(PKGFILE)
	$(UTILDIR)/installpkg.sh $(PKGNAME) $(SYSROOT)

clean:
	$(RM) *.def *.map *.o* *.sym *.lst
	$(RM) -r $(BUILDDIR)

distclean: clean
	$(RM) $(TARGETS) $(HEXFILES) $(PKGFILE)
