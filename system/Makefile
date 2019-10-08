include ../config.mk

.PHONY: all rom os sim clean distclean

all: rom

rom: rom.bin rom.hex

rom.bin: os
	@echo ''
	@echo '--- Building EEPROM Image ---'
	dd bs=1 if=os/os.bin of=rom.bin seek=0 status=none
	dd conv=notrunc bs=1 if=os/romdisk.bin of=rom.bin seek=16384 status=none

rom.hex: rom.bin
	objcopy -I binary -O ihex rom.bin rom.hex

os:
	@echo ''
	@echo '--- Building OS ---'
	@$(MAKE) $(MFLAGS) -C os

clean:
	$(MAKE) -C os/ clean

distclean:
	-$(RM) rom.bin rom.hex
