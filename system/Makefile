include ../Make.config

.PHONY: all bootloader os sim clean distclean

all: rom.bin rom.hex

rom.bin: bootloader/bootloader.bin os/os.bin
	@echo ''
	@echo '--- Building EEPROM Image ---'
	dd bs=1 if=bootloader/bootloader.bin of=rom.bin seek=0 >&/dev/null
	dd conv=notrunc bs=1 if=os/os.bin of=rom.bin seek=16384 >&/dev/null

bootloader bootloader/bootloader.bin:
	@echo ''
	@echo '--- Building Bootloader ---'
	@$(MAKE) $(MAKEFLAGS) -C bootloader

os os/os.bin:
	@echo ''
	@echo '--- Building OS ---'
	@$(MAKE) $(MAKEFLAGS) -C os

rom.hex: rom.bin
	srec_cat rom.bin -binary -o rom.hex -intel

sim: | rom.bin
	zi28sim -r rom.bin & sleep 0.5 && picocom /tmp/zi28sim --omap crcrlf,delbs --send-cmd "ascii-xfr -snvde" --receive-cmd "ascii-xfr -rne"

clean distclean:
	$(MAKE) -C os/ clean
	$(MAKE) -C bootloader/ clean
	-$(RM) rom.bin rom.hex
