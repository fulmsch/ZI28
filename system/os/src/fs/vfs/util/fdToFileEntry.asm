SECTION rom_code
PUBLIC fdToFileEntry

EXTERN getFdAddr, getFileAddr

fdToFileEntry:
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
