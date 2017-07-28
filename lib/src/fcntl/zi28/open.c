#include <fcntl.h>
#include <sys/os.h>

int open(char *name, int flags) {
	#asm
	pop bc ;return address
	pop hl ;flags
	pop de ;filename
	push bc ;return address

	ld a, l ;only lsb is used
	ld c, SYS_open
	rst syscall
	;e = file descriptor
	;a = errno
	cp 0
	jr nz, open_error
	ld h, 0
	ld l, e
	ret
open_error:
	ld hl, -1
	ret
	#endasm
}
