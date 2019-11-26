#code ROM

ft240_read:
;; Read from the USB-connection on the mainboard
;;
;; Input:
;; : ix - file entry addr
;; : (de) - buffer
;; : bc - count
;;
;; Output:
;; : de - count
;; : a - errno
; Errors: 0=no error

#local
	;calculate loop value in bc
	ld a, c
	dec bc
	inc b
	ld c, b
	ld b, a
	ld hl, 0

poll:
	in a, (FT240_STATUS_PORT)
	bit 1, a
	jr nz, poll
	in a, (FT240_DATA_PORT)
	cp 0x04 ;end of text
	jr z, eof
	cp 0x0d ;'\r'
	jr z, poll
	ld (de), a
	inc de
	inc hl
	djnz poll
	dec c
	jr nz, poll
	ex de, hl
	xor a
	ret

eof:
	xor a
	ld (de), a
	ex de, hl
	ret
#endlocal
