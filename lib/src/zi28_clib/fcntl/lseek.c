#include <unistd.h>
#include <fcntl.h>
#include <sys/os.h>
#include <sys/types.h>

off_t lseek(int fd, off_t offset, int whence) {
	#asm
	pop bc ;return address
	pop de ;whence
	pop hl ;offset
	ld (offset), hl
	pop hl ;offset
	ld (offset + 2), hl
	pop hl ;fd
	push bc ;return address

	xor a
	cp h
	jr nz, lseek_error ;fd > 255
	ld a, l

	ld h, e ;whence
	ld de, offset

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

SECTION data_user
offset: defs 4
	#endasm
}
