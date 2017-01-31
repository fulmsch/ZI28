.list
devfs_fsDriver:
	.dw devfs_init
	.dw devfs_open
	.dw devfs_close


.func devfs_init:
;; Adds all permanently attached devices

	;copy filename
	ld de, devfsRoot
	ld hl, tty0name
	ld bc, 8
	ldir
	;register driver address
	ld hl, ft240_fileDriver
	ld a, l
	ld (de), a
	inc de
	ld a, h
	ld (de), a
	inc de
	;dev number
	ld a, 0
	ld (de), a
	inc de
	;attributes (char, rw)
	ld (de), a
	inc de
	;reserved bytes
	inc de
	inc de
	inc de
	;end of devfs
	ld (de), a
	ret


tty0name:
	.asciiz "TTY0"
.endf ;devfs_init


.func devfs_open:

	ret
.endf ;devfs_open


.func devfs_close:

	ret
.endf ;devfs_close
