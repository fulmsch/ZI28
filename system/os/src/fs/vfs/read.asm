#code ROM

u_read:
	add a, fdTableEntries

k_read:
;; Attempts to read up to count bytes from a file descriptor into a buffer.
;;
;; On files that support seeking, the read operation commences at the file
;; offset, and the file offset is incremented by the number of bytes read.
;; If the file offset is at or past the end of file, no bytes are read, and
;; read returns zero.
;;
;; Finds and calls the read routine of the corresponding file driver.
;;
;; Input:
;; : a - file descriptor
;; : (de) - buffer
;; : hl - count
;;
;; Output:
;; : de - count
;; : a - errno
;Errors: 0=no error
;        1=invalid file descriptor

#local
	;TODO limit count to size-offset
	;TODO check permission

	push de ;buffer
	push hl ;count

	;check if fd exists
	call fdToFileEntry
	jr c, invalidFd
	ld a, (hl)
	cp 00h
	jr z, invalidFd

	push hl
	pop ix
;	ld de, fileTableFiledriver
;	add ix, de

	;check for valid file driver
	ld l, (ix + fileTableDriver)
	ld h, (ix + fileTableDriver + 1)
	and a
	ld de, 0
	sbc hl, de
	jr z, invalidDriver;NULL pointer
	ld de, file_read
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl

	pop bc ;count
	pop de ;buffer

	;check if count > 0
	ld a, b
	cp 0
	jr nz, validCount
	ld a, c
	cp 0
	jr z, zeroCount
validCount:
	push ix
	;push return address to stack
	push hl
	ld hl, return
	ex (sp), hl

	jp (hl)

return:
	pop ix
	push de
	;add count to offset
	ld hl, regA
	call ld16 ;load count into reg32
	ld d, h
	ld e, l

	ld b, ixh
	ld c, ixl
	ld hl, fileTableOffset
	add hl, bc
	call add32

	pop de ;count
	xor a
	ret

invalidFd:
	pop hl
	pop hl
	ld a, 1
	ret
invalidDriver:
	pop hl
	pop hl
	ld a, 2
	ret
zeroCount:
	xor a
	ld de, 0
	ret
#endlocal
