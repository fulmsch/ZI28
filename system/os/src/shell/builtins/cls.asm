SECTION rom_code
INCLUDE "string.h"

PUBLIC b_cls
b_cls:
	ld hl, clearSequence
	jp print

clearSequence:
	DEFM 0x1b, "[2J"
	DEFM 0x1b, "[H", 0x00
