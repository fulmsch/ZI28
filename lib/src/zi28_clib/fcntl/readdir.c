#include <sys/stat.h>
#include <sys/os.h>

int readdir(int dirfd, struct stat *buf) {
	#asm
	pop bc ;return address
	pop de ;stat buf
	pop hl ;dirfd
	push bc ;return address
	xor a
	cp h
	jr nz, readdir_error ;fd > 255
	ld a, l
	ld c, SYS_readdir
	rst RST_syscall
	cp 0
	jr nz, readdir_error
	ld h, a
	ld l, a
	ret
readdir_error:
	ld hl, -1
	ret
	#endasm
}
