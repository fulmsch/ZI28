bootloaderStart: equ 0c000h
startsector: equ bootloaderStart + 1c6h
bootsector: equ bootloaderStart + 200h

	org bootloaderStart

	jr start
start:
	;check 1beh if bootable
	;check 1c2h if fat16

	ld b, 0
	ld hl, startsector
	ld c, (hl)
	inc hl
	ld d, (hl)
	inc hl
	ld e, (hl)

	sla c
	rl d
	rl e

	ld a, 1
	ld hl, bootsector

	rst 20h
	rst 38h
