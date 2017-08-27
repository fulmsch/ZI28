#include <fcntl.h>
#include <sys/os.h>

size_t read(int fd, void *buf, size_t count) {
	#asm
	ld hl, 6
	add hl, sp
	ld a, (hl) ;fd
	pop bc ;return address
	pop hl ;count
	pop de ;buffer
	inc sp
	inc sp ;clear fd
	push bc ;return address

	ld c, SYS_read
	rst syscall
	;de = count
	;a = errno
	cp 0
	jr nz, read_error
	ex de, hl
	ret
read_error:
	ld hl, -1
	ret
	#endasm
}
