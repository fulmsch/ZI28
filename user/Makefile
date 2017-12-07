include ../config.mk

IMGFILE = sd.img
MOUNTDIR = mnt

.PHONY: all mount umount unmount clean distclean

all: $(IMGFILE) mount

$(IMGFILE): unmount
	@echo '--- Creating SD image ---'
	$(UTILDIR)/mkimage.sh $(IMGFILE)

mount:
	@echo '--- Mounting SD image ---'
	mkdir -p $(MOUNTDIR)
	-$(UTILDIR)/lomount.sh $(IMGFILE) 1 $(MOUNTDIR)

umount unmount:
	@echo '--- Unmounting SD image ---'
	-sudo umount $(MOUNTDIR)
	$(RM) -r $(MOUNTDIR)

clean:

distclean: unmount
	-$(RM) $(IMGFILE)
