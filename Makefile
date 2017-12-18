include config.mk

.PHONY: all emulator lib rom run user clean distclean

all: emulator lib rom user

emulator:
	@$(MAKE) $(MFLAGS) -C emulator

lib:
	@echo ''
	@echo '--- Building C Libraries ---'
	@$(MAKE) $(MFLAGS) -C lib/

rom:
	@$(MAKE) $(MFLAGS) -C system/ rom

user: lib
	@$(MAKE) $(MFLAGS) -C user/

run:
	emulator/zi28emu -r system/rom.bin & sleep 0.5 && picocom /tmp/zi28tty --omap crcrlf,delbs --send-cmd "ascii-xfr -snvde" --receive-cmd "ascii-xfr -rne"; killall zi28emu

clean:
	-@$(MAKE) -C emulator/ clean
	-@$(MAKE) -C lib/ clean
	-@$(MAKE) -C system/ clean
	-@$(MAKE) -C user/ clean

distclean: clean
	-@$(MAKE) -C emulator/ distclean
	-@$(MAKE) -C lib/ distclean
	-@$(MAKE) -C system/ distclean
	-@$(MAKE) -C user/ distclean

