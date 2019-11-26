; FT240x driver

#code ROM

#define FT240_DATA_PORT   0
#define FT240_STATUS_PORT 1

ft240_deviceDriver:
	DEFW 0x0000 ;init
	DEFW ft240_read
	DEFW ft240_write


#include "read.asm"
#include "write.asm"
