SECTION rom_code
INCLUDE "os.h"
INCLUDE "string.h"
INCLUDE "math.h"
INCLUDE "vfs.h"
INCLUDE "devfs.h"
INCLUDE "os_memmap.h"

PUBLIC devfs_open

EXTERN devfs_fileDriver

devfs_open:
;; Open a device file
;;
;; Input:
;; : ix - table entry
;; : (de) - absolute path
;;
;; Output:
;; : a - errno

; Errors: 0=no error
;         4=no matching file found

	ld a, (de)
	cp 0x00
	jr nz, notRootDir
	;root directory

	;store file driver
	ld a, devfs_fileDriver & 0xff
	ld (ix + fileTableDriver), a
	ld a, devfs_fileDriver >> 8
	ld (ix + fileTableDriver + 1), a

	;store size
	ld de, devfsEntries * devfsEntrySize
	ld b, ixh
	ld c, iyl
	ld hl, fileTableSize
	add hl, bc
	call ld16

	;set type to directory
	ld a, (ix + fileTableMode)
	or M_DIR
	ld (ix + fileTableMode), a

	;set dirEntry pointer to 0 to indicate root dir
	xor a
	ld (ix + dev_fileTableDirEntry), a
	ld (ix + dev_fileTableDirEntry + 1), a

	ret


notRootDir:
	ld hl, devfsRoot
	push de ;path
	push hl ;file entry
	ld b, 8
	call strncmp
	jr z, fileFound

fileSearchLoop:
	ld de, devfsEntrySize
	pop hl ;file entry
	add hl, de
	pop de ;path
	ld a, (hl)
	cp 0
	jr z, invalidFile
	push de ;path
	push hl ;file entry
	ld b, 8
	call strncmp
	jr nz, fileSearchLoop

fileFound:
	pop iy ;pointer to devfs file entry
	pop de ;path, not needed anymore

	;copy file information
	ld a, (iy + devfs_entryDriver)
	ld (ix + fileTableDriver), a
	ld a, (iy + devfs_entryDriver + 1)
	ld (ix + fileTableDriver + 1), a

	ld a, (iy + devfs_number)
	ld (ix + dev_fileTableNumber), a

	;copy custom data
	ld bc, devfsEntrySize - devfs_data
	ld d, ixh
	ld e, ixl
	ld hl, dev_fileTableData
	add hl, de
	push hl
	ld d, iyh
	ld e, iyl
	;store dirEntry pointer while we have a pointer in a register
	ld (ix + dev_fileTableDirEntry), e
	ld (ix + dev_fileTableDirEntry + 1), d
	ld hl, devfs_data
	add hl, de
	pop de
	ldir

	;store filetype TODO add distincion between char and block devs
	ld a, (ix + fileTableMode)
	or M_CHAR
	ld (ix + fileTableMode), a

	;operation succesful
	xor a
	ret

invalidFile:
	ld a, 4
	ret
