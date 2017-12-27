#include <fcntl.h>
#include <sys/os.h>

int unlink(const char *pathname) {
	#asm
	;hl = fd
	ex de, hl
	ld c, SYS_unlink
	rst RST_syscall
	cp 0
	jr nz, unlink_error
	ld h, a
	ld l, a
	jr unlink_end
unlink_error:
	ld hl, -1
unlink_end:
	#endasm
}
