include Make.config

.PHONY: all emulator lib rom run clean distclean

all: emulator lib rom

emulator:
	@$(MAKE) $(MFLAGS) -C emulator

lib:
	@echo ''
	@echo '--- Building C Libraries ---'
	@$(MAKE) $(MFLAGS) -C lib/

rom:
	@$(MAKE) $(MFLAGS) -C system/ rom


run:
	emulator/zi28emu -r system/rom.bin & sleep 0.5 && picocom /tmp/zi28tty --omap crcrlf,delbs --send-cmd "ascii-xfr -snvde" --receive-cmd "ascii-xfr -rne"

clean:
	@$(MAKE) -C emulator/ clean
	@$(MAKE) -C lib/ clean
	@$(MAKE) -C system/ clean

distclean: clean
	@$(MAKE) -C emulator/ distclean
	@$(MAKE) -C lib/ distclean
	@$(MAKE) -C system/ distclean

