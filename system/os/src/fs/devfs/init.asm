#code ROM

devfs_init:
;; Adds all permanently attached devices
#local
	;ft240
	ld hl, tty0name
	ld de, ft240_deviceDriver
	ld a, 0
	call devfs_addDev


	ld hl, sdaName
	ld de, sd_deviceDriver
	ld a, 0x80
	call devfs_addDev

	;; ld hl, vgattyName
	;; ld de, vt100_deviceDriver
	;; ld a, 0x90
	;; call devfs_addDev


	xor a
	ret


tty0name:
	DEFM "TTY0", 0x00
sdaName:
	DEFM "SDA", 0x00
vgattyName:
	DEFM "VGATTY", 0x00
#endlocal
