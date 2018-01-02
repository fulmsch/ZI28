SECTION rom_code
PUBLIC fat_build83Filename

fat_build83Filename:
;; Convert a filename to the FAT 8.3 format.
;;
;; Input:
;; : (hl) - filename (must be uppercase)
;; : (de) - output buffer (length: 11 bytes)
;;
;; Output:
;; : carry - invalid filename
;; : hl - if succesful, points to char after filename (0x00 or '/')

	;clear the buffer
	push de ;buffer
	push hl ;filename
	ld h, d
	ld l, e
	inc de
	ld bc, 10
	ld (hl), ' '
	ldir
	pop hl ;filename
	pop de ;buffer

	ld b, 2
	ld c, 8

loop:
	ld a, (hl)
	cp 0x00
	ret z
	cp '/'
	ret z
	cp '.'
	jr z, dot

	;check if printable
	cp 0x21
	jr c, error
	cp 0x7f
	jr nc, error

	push de
	ld de, illegalChars
checkIllegal:
	;check if character is illegal
	ld a, (de)
	inc de
	cp (hl)
	jr z, illegal
	cp 0x00
	jr nz, checkIllegal

	pop de

	xor a
	cp c
	jr z, error
	ldi ;(de) = (hl), bc--
	jr loop

	;basename or extension too long
error:
	scf
	ret

dot:
	dec b
	jr z, error ;only one dot allowed
	ld a, 8
	cp c
	jr z, error
	xor a
	cp c
	jr z, extLoopEnd
extLoop:
	inc de
	dec c
	jr nz, extLoop
extLoopEnd:
	inc hl
	ld c, 3
	jr loop

illegal:
	pop de
	scf
	ret

illegalChars:
	DEFB '|', '<', '>', '^', '+', '=', '?', '[', ']', ';', ',', '*', '\\', '"', 0x00
