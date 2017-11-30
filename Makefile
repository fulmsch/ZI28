.PHONY: all rom os bootloader clean distclean docs sim lib

all: rom lib

lib:
	@echo ''
	@echo '--- Building C Libraries ---'
	@$(MAKE) -j -C lib/

rom: bootloader os rom.bin rom.hex

rom.bin: bootloader/bootloader.bin os/os.bin
	@echo ''
	@echo '--- Building EEPROM Image ---'
	dd bs=1 if=bootloader/bootloader.bin of=rom.bin seek=0 >&/dev/null
	dd conv=notrunc bs=1 if=os/os.bin of=rom.bin seek=16384 >&/dev/null

bootloader:
	@echo ''
	@echo '--- Building Bootloader ---'
	$(MAKE) -C bootloader

os:
	@echo ''
	@echo '--- Building OS ---'
	$(MAKE) -C os

rom.hex: rom.bin
	srec_cat rom.bin -binary -o rom.hex -intel

sim: | rom.bin
	zi28sim -r rom.bin & sleep 0.5 && picocom /tmp/zi28sim --omap crcrlf,delbs --send-cmd "ascii-xfr -snvde" --receive-cmd "ascii-xfr -rne"

clean:
	$(MAKE) -C lib/ clean

distclean: clean
	$(MAKE) -C lib/ distclean
	$(MAKE) -C os/ clean
	$(MAKE) -C bootloader/ clean
	-$(RM) rom.bin rom.hex

