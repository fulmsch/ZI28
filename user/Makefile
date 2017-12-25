include ../config.mk

IMGFILE = sd.img
IMGSIZE = 600000 #in KiB
MOUNTDIR = $(SYSROOT)
PKGLIST = all.pkglist

MAKEDIRS = $(dir $(shell find . -mindepth 2 -iname "Makefile"))

.PHONY: all mount umount unmount applications buildfs clean distclean

all: buildfs

BASEFS.TZ7:
	mkdir -p basefs basefs/BIN basefs/CFG basefs/DEV basefs/DOC basefs/GAMES basefs/HOME basefs/MNT basefs/SYS basefs/TMP basefs/VAR basefs/VAR/LOG basefs/VAR/LOG/PACKAGES basefs/VAR/LOG/PACKAGES/REMOVED
	$(UTILDIR)/makepkg.sh basefs BASEFS
	$(RM) -r basefs

$(IMGFILE): unmount
	@echo '--- Creating SD image ---'
	$(UTILDIR)/mkimage.sh $(IMGFILE) $(IMGSIZE)

mount:
	@if [ ! -f $(IMGFILE) ]; then \
		echo '--- SD image does not exist, creating it first ---'; \
		$(MAKE) $(IMGFILE); \
	fi
	@if  ! mountpoint -q $(MOUNTDIR); then \
		echo '--- Mounting SD image ---'; \
		mkdir -p $(MOUNTDIR); \
		$(UTILDIR)/lomount.sh $(IMGFILE) 1 $(MOUNTDIR); \
	fi

buildfs: applications BASEFS.TZ7
	$(MAKE) mount
	$(UTILDIR)/buildfs.sh $(MOUNTDIR) $(PKGLIST)

umount unmount:
	@if mountpoint -q $(MOUNTDIR); then \
		echo '--- Unmounting SD image ---'; \
		sudo umount $(MOUNTDIR); \
		$(RM) -r $(MOUNTDIR); \
	fi

applications:
	@for DIR in $(MAKEDIRS); do \
		$(MAKE) -C $$DIR --no-print-directory; \
	done

clean:
	-@for DIR in $(MAKEDIRS); do \
		$(MAKE) -C $$DIR clean --no-print-directory; \
	done

distclean: unmount
	-$(RM) $(IMGFILE) BASEFS.TZ7
	-@for DIR in $(MAKEDIRS); do \
		$(MAKE) -C $$DIR distclean --no-print-directory; \
	done
