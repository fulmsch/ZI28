SECTION rom_code
INCLUDE "vfs.h"

PUBLIC u_close, k_close

EXTERN getFileAddr, getFdAddr

u_close:
	add a, fdTableEntries

k_close:
;; Close a file
;;
;; Closes a file descriptor. If the file has no more references, it gets closed too.
;;
;; Input:
;; : a - file descriptor
;;
;; Output:
;; : a - errno
;Errors: 0=no error
;        1=invalid file descriptor

	call getFdAddr
	jr c, invalidFd
	ld a, (hl)
	;check if fd exists
	cp 0xff
	jr z, invalidFd
	ld (hl), 0xff
	call getFileAddr

	inc hl
	dec (hl)
	ret nz ;more references to the file
	dec hl

	xor a
	ld b, fileTableEntrySize
clearEntry:
	ld (hl), a
	inc hl
	djnz clearEntry

	xor a
	ret

invalidFd:
	ld a, 1
	ret
