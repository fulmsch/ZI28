#define fileTableMode        0                        ;1 byte
#define fileTableRefCount    fileTableMode + 1        ;1 byte
#define fileTableDriveNumber fileTableRefCount + 1    ;1 byte
#define fileTableDriver      fileTableDriveNumber + 1 ;2 bytes
#define fileTableOffset      fileTableDriver + 2      ;4 bytes
#define fileTableSize        fileTableOffset + 4      ;4 bytes
                                                      ;-------
                                               ;Total 13 bytes
#define fileTableData        fileTableSize + 4  ;Max   19 bytes


#define file_read  0
#define file_write 2

#define fileTableEntrySize 32
#define fileTableEntries   32

#define fdTableEntries 32

#data RAM
	;; TODO align
;; SECTION ram_fileTable
fileTable:
	defs fileTableEntries * fileTableEntrySize

	;; TODO align
;; SECTION ram_fdTable
k_fdTable:
	defs fdTableEntries
u_fdTable:
	defs fdTableEntries

#code ROM

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

#local
	call getFdAddr
	ret c
	ld a, (hl)
	;a = file table index
	jp getFileAddr

error:
	scf
	ret
#endlocal


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

#local
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
#endlocal


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


#include "close.asm"
#include "dup.asm"
#include "open.asm"
#include "read.asm"
#include "readdir.asm"
#include "seek.asm"
#include "stat.asm"
#include "udup.asm"
#include "unlink.asm"
#include "write.asm"
