#include <sys/stat.h>
#include <sys/os.h>

int stat(char *filename, struct stat *buf) {
	#asm
	pop bc ;return address
	pop hl ;stat buf
	pop de ;filename
	push bc ;return address
	ld c, SYS_stat
	rst syscall
	cp 0
	jr nz, stat_error
	ld h, a
	ld l, a
	ret
stat_error:
	ld hl, -1
	ret
	#endasm
}
