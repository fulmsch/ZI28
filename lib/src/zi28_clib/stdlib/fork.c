#include <unistd.h>
#include <sys/os.h>
#include <errno.h>

int fork(void) {
	#asm

	ld c, SYS_fork
	rst RST_syscall

	ld hl, _errno
	ld (hl), 0
	inc hl
	ld (hl), e ;errno

	ld h, 0
	ld l, a

	cp 0xff
	ret nz
	ld h, a
	ret
	#endasm
}
