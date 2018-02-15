#include <unistd.h>
#include <sys/os.h>

int execv(char *path, char **argv) {
	#asm
	pop bc ;return address
	pop hl ;argv
	pop de ;path
	push bc ;return address

	ld c, SYS_execv
	rst RST_syscall
	;only returns on error
	;a = errno
execv_error:
	;TODO set errno
	ld hl, -1
	ret
	#endasm
}
