#include <fcntl.h>
#include <sys/os.h>

int close(int fd) {
//	if (fd > 255) {
//		return -1;
//	}
	#asm
	;hl = fd
	ld a, l
	ld c, SYS_close
	rst RST_syscall
	cp 0
	jr nz, close_error
	ld h, a
	ld l, a
	jr close_end
close_error:
	ld hl, -1
close_end:
	#endasm
}
