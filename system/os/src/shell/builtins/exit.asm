SECTION rom_code
INCLUDE "os.h"
INCLUDE "string.h"
INCLUDE "cli.h"
INCLUDE "iomap.h"

PUBLIC b_exit
b_exit:
	ld a, (argc)
	cp 1
	jr nz, invalidCall

	ld hl, bankSwitch
	ld de, 0x8000
	ld bc, bankSwitchEnd - bankSwitch
	ldir
	jp 0x8000

bankSwitch:
	xor a
	out (BANKSEL_PORT), a
	dec a
	rst 0
bankSwitchEnd:

invalidCall:
	ret