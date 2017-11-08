ROOTDIR = .
UTILDIR = $(ROOTDIR)/utils
INCLUDEDIR = $(ROOTDIR)/include

.PHONY: all rom os bootloader clean docs sim

all: rom

rom: bootloader os rom.bin rom.hex

clean:
	$(MAKE) -C bootloader clean
	$(MAKE) -C os clean
	-rm rom.bin rom.hex

rom.bin: bootloader/bootloader.bin os/os.bin
	dd bs=1 if=bootloader/bootloader.bin of=rom.bin seek=0 >&/dev/null
	dd conv=notrunc bs=1 if=os/os.bin of=rom.bin seek=16384 >&/dev/null

bootloader:
	$(MAKE) -C bootloader

os:
	$(MAKE) -C os

rom.hex: rom.bin
	srec_cat rom.bin -binary -o rom.hex -intel

sim: | rom.bin
	zi28sim -r rom.bin & sleep 0.5 && picocom /tmp/zi28sim --omap crcrlf,delbs --send-cmd "ascii-xfr -snvde" --receive-cmd "ascii-xfr -rne"
