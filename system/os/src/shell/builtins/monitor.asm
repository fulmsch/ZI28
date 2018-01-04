MODULE builtin_monitor

SECTION rom_code
INCLUDE "os.h"

PUBLIC b_monitor
b_monitor:
	rst RST_monitor
	ret
