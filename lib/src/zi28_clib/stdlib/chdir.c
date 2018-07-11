#include <unistd.h>
#include <sys/os.h>
#include <errno.h>

int chdir(char *path) {
	#asm

	;hl = path

	ld c, SYS_chdir
	rst RST_syscall

	cp 0
	jr nz, error
	ld h, a
	ld l, a
	jr end

error:
	ld hl, _errno
	ld (hl), 0
	inc hl
	ld (hl), a ;errno

	ld hl, -1

end:
	#endasm
}
