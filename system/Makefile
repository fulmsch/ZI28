include ../config.mk

.PHONY: all rom bootloader os sim clean distclean

all: rom

rom: rom.bin rom.hex

rom.bin: bootloader os
	@echo ''
	@echo '--- Building EEPROM Image ---'
	dd bs=1 if=bootloader/bootloader.bin of=rom.bin seek=0 status=none
	dd conv=notrunc bs=1 if=os/os.bin of=rom.bin seek=16384 status=none

rom.hex: rom.bin
	objcopy -I binary -O ihex rom.bin rom.hex

bootloader:
	@echo ''
	@echo '--- Building Bootloader ---'
	@$(MAKE) $(MFLAGS) -C bootloader

os:
	@echo ''
	@echo '--- Building OS ---'
	@$(MAKE) $(MFLAGS) -C os

clean:
	$(MAKE) -C os/ clean
	$(MAKE) -C bootloader/ clean

distclean:
	-$(RM) rom.bin rom.hex
