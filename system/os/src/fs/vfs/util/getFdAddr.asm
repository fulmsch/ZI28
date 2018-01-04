SECTION rom_code
INCLUDE "vfs.h"

PUBLIC getFdAddr

getFdAddr:
;; Get the address of a file descriptor
;;
;; Input:
;; : a - fd
;;
;; Output:
;; : hl - fd address
;; : carry - error
;; : nc - no error
;;
;; Destroyed:
;; : a, hl, de

	;check if fd in range
	cp fdTableEntries*2
	jr nc, error

	ld hl, k_fdTable
	;a = fd
	;hl = fd table base addr
	ld d, 0
	ld e, a
	add hl, de ;this should reset the carry flag
	ret

error:
	scf
	ret
