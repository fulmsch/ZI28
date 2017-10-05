.list

.func fat_readdir:
;; Get information about the next file in a directory.
;;
;; Input:
;; : a - dirfd
;; : (de) - stat
;;
;; Output:
;; : a - errno

	push de
	push af

readLoop:
	pop af
	push af
	ld de, fat_dirEntryBuffer
	ld hl, 32
	push de
	call k_read
	pop hl

	;TODO check for EOF
	;hl = fat_dirEntryBuffer
	ld a, (hl)
	cp 0x00 ;end of dir reached, no match
	jp z, error
	cp 0xe5 ;deleted file
	jr z, readLoop
	cp 0x20 ;empty filename
	jr z, readLoop

	pop af
	pop de
	jp fat_statFromEntry



error:
	pop af
	pop de
	ld a, 1
	ret
.endf
