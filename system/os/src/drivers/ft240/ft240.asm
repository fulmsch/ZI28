SECTION rom_code
; FT240x driver

INCLUDE "drivers/ft240.h"

PUBLIC ft240_fileDriver

ft240_fileDriver:
	DEFW ft240_read
	DEFW ft240_write
