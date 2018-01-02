SECTION rom_code
INCLUDE "os_memmap.h"

PUBLIC getFileAddr

EXTERN getTableAddr

getFileAddr:
;; Finds the file entry of a given fd
;;
;; Input:
;; : a - file descriptor
;;
;; Output:
;; : hl - table entry address
;; : carry - out of bounds
;; : nc - no error
;;
;; See also:
;; : [getTableAddr](drive.asm.html#getTableAddr)

	;TODO optimise by using an aligned table and bitshifts

	ld hl, fileTable
	ld de, fileTableEntrySize
	ld b, fileTableEntries
	jp getTableAddr
