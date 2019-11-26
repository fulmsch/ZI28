include ../config.mk

.PHONY: all rom bank0 os sim clean distclean

all: rom

rom: rom.bin rom.hex

rom.bin: bank0 os
	@echo ''
	@echo '--- Building EEPROM Image ---'
	dd bs=1 if=bank0/bank0.bin of=rom.bin seek=0 status=none
	dd conv=notrunc bs=1 if=os/os.bin of=rom.bin seek=16384 status=none

rom.hex: rom.bin
	objcopy -I binary -O ihex rom.bin rom.hex

bank0:
	@echo ''
	@echo '--- Building Bootloader ---'
	@$(MAKE) $(MFLAGS) -C bank0

os:
	@echo ''
	@echo '--- Building OS ---'
	@$(MAKE) $(MFLAGS) -C os

clean:
	$(MAKE) -C os/ clean
	$(MAKE) -C bank0/ clean

distclean:
	-$(RM) rom.bin rom.hex
	$(MAKE) -C os/ distclean
	$(MAKE) -C bank0/ distclean
