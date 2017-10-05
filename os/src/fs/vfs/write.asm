.list

u_write:
	add a, fdTableEntries

.func k_write:
;; Write to an open file
;;
;; Finds and calls the write routine of the corresponding file driver.
;;
;; Input:
;; : a - file descriptor
;; : (de) - buffer
;; : hl - count
;;
;; Output:
;; : de - count
;; : a - errno
; Errors: 0=no error
;         1=invalid file descriptor
;         2=invalid file driver

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
	
	;a still contains fileTable_mode
	bit M_APPEND_BIT, a
	jr z, skipAppend
	;set offset to size hl size  de offset
	ld de, fileTableOffset
	add hl, de
	ld d, h
	ld e, l
	ld bc, fileTableSize-(fileTableOffset)
	add hl, bc
	call ld32

skipAppend:
	;check for valid file driver
	ld l, (ix + fileTableDriver)
	ld h, (ix + fileTableDriver + 1)
	and a
	ld de, 0
	sbc hl, de
	jr z, invalidDriver;NULL pointer
	ld de, file_write
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

	;call file driver
	jp (hl)

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
.endf
