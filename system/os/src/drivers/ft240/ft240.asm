SECTION rom_code
; FT240x driver

INCLUDE "drivers/ft240.h"

PUBLIC ft240_deviceDriver

ft240_deviceDriver:
	DEFW 0x0000 ;init
	DEFW ft240_read
	DEFW ft240_write
