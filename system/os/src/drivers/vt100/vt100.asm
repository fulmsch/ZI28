SECTION rom_code

INCLUDE "drivers/vt100.h"

PUBLIC vt100_deviceDriver

vt100_deviceDriver:
	DEFW vt100_init
	DEFW vt100_read
	DEFW vt100_write
