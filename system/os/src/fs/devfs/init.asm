MODULE devfs_init

SECTION rom_code
INCLUDE "math.h"

PUBLIC devfs_init

EXTERN ft240_deviceDriver, devfs_addDev, sd_deviceDriver

devfs_init:
;; Adds all permanently attached devices

	;ft240
	ld hl, tty0name
	ld de, ft240_deviceDriver
	ld a, 0
	call devfs_addDev

	ld hl, sdaName
	ld de, sd_deviceDriver
	ld a, 0
	call devfs_addDev


	xor a
	ret


tty0name:
	DEFM "TTY0", 0x00
sdaName:
	DEFM "SDA", 0x00
