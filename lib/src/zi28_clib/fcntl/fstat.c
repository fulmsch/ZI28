#include <sys/stat.h>
#include <sys/os.h>

int fstat(int fd, struct stat *buf) {
	#asm
	pop bc ;return address
	pop de ;stat buf
	pop hl ;fd
	push bc ;return address
	xor a
	cp h
	jr nz, fstat_error ;fd > 255
	ld a, l
	ld c, SYS_fstat
	rst RST_syscall
	cp 0
	jr nz, fstat_error
	ld h, a
	ld l, a
	ret
fstat_error:
	ld hl, -1
	ret
	#endasm
}
