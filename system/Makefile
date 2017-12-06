include ../Make.config

.PHONY: all rom bootloader os sim clean distclean

all: rom

rom: rom.bin rom.hex

rom.bin: bootloader/bootloader.bin os/os.bin
	@echo ''
	@echo '--- Building EEPROM Image ---'
	dd bs=1 if=bootloader/bootloader.bin of=rom.bin seek=0 >&/dev/null
	dd conv=notrunc bs=1 if=os/os.bin of=rom.bin seek=16384 >&/dev/null

rom.hex: rom.bin
	objcopy -I binary -O ihex rom.bin rom.hex

bootloader bootloader/bootloader.bin:
	@echo ''
	@echo '--- Building Bootloader ---'
	@$(MAKE) $(MFLAGS) -C bootloader

os os/os.bin:
	@echo ''
	@echo '--- Building OS ---'
	@$(MAKE) $(MFLAGS) -C os

sim: | rom.bin
	zi28sim -r rom.bin & sleep 0.5 && picocom /tmp/zi28sim --omap crcrlf,delbs --send-cmd "ascii-xfr -snvde" --receive-cmd "ascii-xfr -rne"

clean:
	$(MAKE) -C os/ clean
	$(MAKE) -C bootloader/ clean

distclean:
	-$(RM) rom.bin rom.hex
