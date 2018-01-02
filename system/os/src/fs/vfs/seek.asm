SECTION rom_code
INCLUDE "os.h"
INCLUDE "math.h"
INCLUDE "vfs.h"
INCLUDE "os_memmap.h"

EXTERN fdToFileEntry

PUBLIC u_seek, k_seek, u_lseek, k_lseek

u_lseek:
	add a, fdTableEntries
	jp k_lseek

u_seek:
	add a, fdTableEntries

k_seek:
;; Change the file offset of an open file using a 16-bit offset.
;;
;; The new offset is calculated according to whence as follows:
;;
;; * `SEEK_SET` : from start of file
;; * `SEEK_CUR` : from current location in positive direction
;; * `SEEK_END` : from end of file in positive direction
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
	ld hl, regA
	call ld16
	ld d, h
	ld e, l
	pop hl


k_lseek:
;; Change the file offset of an open file using a 32-bit offset.
;;
;; The new offset is calculated according to whence as follows:
;;
;; * `SEEK_SET` : from start of file
;; * `SEEK_CUR` : from current location in positive direction
;; * `SEEK_END` : from end of file in positive direction
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
	cp SEEK_SET
	jr z, set
	cp SEEK_CUR
	jr z, cur
	cp SEEK_END
	jr z, end
	jr nz, invalidWhence


end:
	ld de, fileTableSize
	add hl, de
	ld de, k_seek_new
	call ld32
	jr addOffs

cur:
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

	ld de, fileTableOffset
	add hl, de
	ld de, k_seek_new
	ld a, (de)
	bit 7, a
	jr nz, invalidOffset
	push hl
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
