#include <unistd.h>
#include <fcntl.h>
#include <sys/os.h>
#include <sys/types.h>

off_t lseek(int fd, off_t offset, int whence) {
	#asm
	pop bc ;return address
	pop de ;whence
	pop hl ;offset
	pop hl ;offset
	pop hl ;fd
	push bc ;return address

	xor a
	cp h
	jr nz, lseek_error ;fd > 255
	ld a, l

	ld hl, 0
	add hl, sp
	ex de, hl
	ld l, h

	ld c, SYS_lseek
	rst RST_syscall
	cp 0
	jr nz, lseek_error

	ex de, hl
	ld c, (hl)
	inc hl
	ld b, (hl)
	inc hl
	ld e, (hl)
	inc hl
	ld d, (hl)

	ld h, b
	ld l, c
	ret
lseek_error:
	ld de, 0xff
	ld hl, -1
	ret
	#endasm
}
