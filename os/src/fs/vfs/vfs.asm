;; 
.list

.func getFileAddr:
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
.endf

.func fdToFileEntry:
;; Finds the file entry of a given fd
;;
;; Input:
;; : a - file descriptor
;;
;; Output:
;; : hl - table entry address
;; : carry - error
;; : nc - no error


	call getFdAddr
	ret c
	ld a, (hl)
	;a = file table index
	jp getFileAddr

error:
	scf
	ret
.endf

.func getFdAddr:
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
.endf

.include "fs/vfs/open.asm"
.include "fs/vfs/close.asm"
.include "fs/vfs/dup.asm"
.include "fs/vfs/udup.asm"
.include "fs/vfs/readdir.asm"
.include "fs/vfs/stat.asm"
.include "fs/vfs/read.asm"
.include "fs/vfs/write.asm"
.include "fs/vfs/seek.asm"
