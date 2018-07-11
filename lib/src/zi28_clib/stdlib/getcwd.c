#include <unistd.h>
#include <sys/os.h>
#include <errno.h>

char *getcwd(char *buf) {
	#asm

	;hl = buf
	push hl

	ld c, SYS_getcwd
	rst RST_syscall

	pop hl
	cp 0
	jr z, end
	

error:
	ld hl, _errno
	ld (hl), 0
	inc hl
	ld (hl), a ;errno

	ld hl, 0

end:
	#endasm
}
