#include <string.h>
#include <sys/os.h>

char *strerror(int errnum) {
	#asm
	;hl = errnum
	ld a, l
	rst RST_strerror
	#endasm
}
