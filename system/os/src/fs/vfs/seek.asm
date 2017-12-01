.list

.func u_lseek:
	add a, fdTableEntries
	jp k_lseek
.endf

u_seek:
	add a, fdTableEntries

k_seek:
;; Change the file offset of an open file using a 16-bit offset.
;;
;; The new offset is calculated according to whence as follows:
;;
;; * `K_SEEK_SET` : from start of file
;; * `K_SEEK_PCUR` : from current location in positive direction
;; * `K_SEEK_NCUR` : from current location in negative direction
;; * `K_SEEK_END` : from end of file in negative direction
;;
;; Input:
;; : a - file descriptor
;; : de - offset
;; : h - whence
;;
;; Output:
;; : (de) - new offset from start of file
;; : a - errno

	push hl
	ld hl, reg32
	call ld16
	ld d, h
	ld e, l
	pop hl


.func k_lseek:
;; Change the file offset of an open file using a 32-bit offset.
;;
;; The new offset is calculated according to whence as follows:
;;
;; * `K_SEEK_SET` : from start of file
;; * `K_SEEK_PCUR` : from current location in positive direction
;; * `K_SEEK_NCUR` : from current location in negative direction
;; * `K_SEEK_END` : from end of file in negative direction
;;
;; Input:
;; : a - file descriptor
;; : (de) - offset
;; : h - whence
;;
;; Output:
;; : (de) - new offset from start of file
;; : a - errno
; Errors: 0=no error
;         1=invalid file descriptor
;         2=whence is invalid
;         3=the resulting offset would be invalid

	push hl ;h = whence
	push de ;offset

	;check if fd exists, get the address
	call fdToFileEntry
	pop de ;offset
	pop bc ;b = whence
	jp c, invalidFd
	ld a, (hl)
	cp 00h
	jp z, invalidFd
	;hl=table entry addr

	push hl ;table entry
	push de ;offset

	;check whence
	ld a, b
	cp K_SEEK_SET
	jr z, set
	cp K_SEEK_END
	jr z, end
	cp K_SEEK_PCUR
	jr z, pcur
	cp K_SEEK_NCUR
	jr nz, invalidWhence

ncur:
	ld de, fileTableOffset
	add hl, de
	ld de, k_seek_new
	call ld32
	jr subOffs

end:
	ld de, fileTableSize
	add hl, de
	ld de, k_seek_new
	call ld32

subOffs:
	;new=new-offs
	ld hl, k_seek_new
	pop de ;offset
	push de
	call cp32
	pop de
	jr c, invalidOffset

	ld hl, k_seek_new
	ex de, hl
	call sub32

	pop hl ;table entry addr

	ld de, fileTableOffset
	add hl, de
	push hl
	ld de, k_seek_new
	call ld32

	pop de
	xor a
	ret


pcur:
	ld de, fileTableOffset
	add hl, de
	ld de, k_seek_new
	call ld32
	jr addOffs

set:
	ld hl, k_seek_new
	call clear32

addOffs:
	;new=new+offs
	ld hl, k_seek_new
	pop de ;offset
	call add32

	pop hl ;table entry
	push hl
	ld de, fileTableSize
	add hl, de
	ex de, hl
	ld hl, k_seek_new
	call cp32
	pop hl
	;TODO reenable size checking
	;jr nc, invalidOffset

	ld de, fileTableOffset
	add hl, de
	push hl
	ld de, k_seek_new
	ex de, hl
	call ld32

	pop de
	xor a
	ret


invalidFd:
	ld a, 1
	ret
invalidWhence:
	ld a, 2
	ret
invalidOffset:
	ld a, 3
	ret
.endf
