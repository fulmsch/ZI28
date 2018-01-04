SECTION rom_code
INCLUDE "os.h"
INCLUDE "string.h"
INCLUDE "cli.h"

EXTERN fat_fsDriver
EXTERN sd_init, k_open, k_mount

PUBLIC b_mount
b_mount:
	ld a, (argc)
	cp 3
	jr nz, invalidCall

	call sd_init

	ld hl, argv
	inc hl
	inc hl

	ld e, (hl)
	inc hl
	ld d, (hl)
	inc hl
	;(de) = device name

	ld c, (hl)
	inc hl
	ld b, (hl)
	ld h, b
	ld l, c
	;(hl) = label
	push hl
	call strtup

	ld a, O_RDWR
	call k_open
	cp 0
	pop hl ;(hl) = label
	jr nz, invalidCall
	;e = fd
	;TODO check if device
	ld a, e

	ld de, fat_fsDriver
	jp k_mount

invalidCall:
	ld hl, invalidCallstr
	call print
	ret
invalidCallstr:
	DEFM "Usage: MOUNT <DEVICE> <LABEL>\n", 0x00
