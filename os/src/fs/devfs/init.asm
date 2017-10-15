.list

.func devfs_init:
;; Adds all permanently attached devices

	;ft240
	ld hl, tty0name
	ld de, ft240_fileDriver
	ld a, 0
	call devfs_addDev

	ld hl, sdaName
	ld de, sd_fileDriver
	ld a, 0
	call devfs_addDev

	ld hl, sda1Name
	ld de, sd_fileDriver
	ld a, 1
	call devfs_addDev
	call clear32

;sd.img on laptop
	ld de, 0x0800
	call ld16

;;sd.img on desktop
;	ld a, 89h
;	call ld8

	xor a
	ret


tty0name:
	.asciiz "TTY0"
sdaName:
	.asciiz "SDA"
sda1Name:
	.asciiz "SDA1"
.endf ;devfs_init
