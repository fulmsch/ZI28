INCLUDE "asm/os.h"

ORG MEM_user

restart:
	xor a
	out (0x93), a

	ld c, 0x97
	ld b, 128
	ld e, 192
loop:
	out (c), b
	djnz loop
	dec e
	jr nz, loop

	ld c, SYS_exit
	xor a
	rst RST_syscall
