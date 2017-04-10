.list

.func b_mount:
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

	ld a, (de)
	sub '0'
	jr c, invalidCall
	cp 10
	jr nc, invalidCall
	;a = drive number
	push af

	ld e, (hl)
	inc hl
	ld d, (hl)

;	call k_open
;	cp 0
	pop af
;	jr nz, invalidCall
	;e = fd
	;TODO check if device

	ld h, e


	ld de, fat_fsDriver
	jp k_mount

invalidCall:
	ld hl, invalidCallstr
	call printStr
	ret
invalidCallstr:
	.asciiz "Usage: MOUNT <DRIVENR> <DEVICE>\r\n"
.endf ;b_mount
