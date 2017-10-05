.list

.func fat_init:
;; Calculate and store filesystem offsets
;;
;; Input:
;;; : a - fd of device containing the fs
;; : ix - drive table entry address

	;TODO fix this crap


	;Store the sector of the first FAT
	ld d, ixh
	ld e, ixl
	ld hl, fat_fat1StartAddr
	add hl, de
	push hl ;fat1StarAddr
	call clear32

	ld a, (ix + driveTableDevfd)
	push af
	push ix
	ld de, FAT_VBR_RESERVED_SECTORS
	ld h, K_SEEK_SET
	call k_seek
	pop ix
	pop af

	pop de ;fat1StarAddr
	push de
	push af
	push ix
	ld hl, 1
	call k_read
	pop ix
	pop af

	pop hl ;fat1StartAddr
	call lshift9_32

	;Calculate the sector of the second FAT
	ld d, h
	ld e, l
	ld bc, fat_fat2StartAddr - (fat_fat1StartAddr)
	add hl, bc
	call clear32
	push de ;fat_fat1StartAddr
	push hl ;fat_fat2StartAddr

	push af
	push ix
	ld de, FAT_VBR_SECTORS_PER_FAT
	ld h, K_SEEK_SET
	call k_seek
	pop ix
	pop af

	pop de ;fat_fat2StartAddr
	push de

	push af
	push ix
	ld hl, 2
	call k_read
	pop ix
	pop af

	pop hl ;fat2StartAddr
	call lshift9_32
	;(fat_fat2StartAddr) = bytes per fat

	ld d, h
	ld e, l
	ld bc, fat_rootDirStartAddr - (fat_fat2StartAddr)
	add hl, bc
	ex de, hl
	;hl = fat_fat2StartAddr
	;de = fat_rootDirStartAddr
	call ld32
	ld b, d
	ld c, e

	pop de ;fat_fat1StartAddr
	call add32 ;fat2StartAddr = bytes_per_fat + fat1StartAddr
	ex de, hl ;de = fat2StartAddr
	ld h, b
	ld l, c
	call add32 ;rootDirStartAddr = bytes_per_fat + fat2StartAddr
	push hl ;rootDirStartAddr


	;Calculate the start of the data region
	;hl = fat_rootDirStartAddr
	ld de, fat_dataStartAddr - (fat_rootDirStartAddr)
	add hl, de
	;hl = fat_dataStartAddr
	call clear32
	push hl ;fat_dataStartAddr

	push af
	push ix
	ld de, FAT_VBR_MAX_ROOT_DIR_ENTRIES
	ld h, K_SEEK_SET
	call k_seek
	pop ix
	pop af

	pop de ;fat_dataStartAddr
	push de
	push af
	push ix
	ld hl, 2
	call k_read
	pop ix
	pop af

	;Calculate the length of the root dir
	;Length in sectors = n_entries * size of entry
	;                  = n_entries * 32 = n_entries << 5
	pop hl
	ld b, 5
rootDirSizeLoop:
	call lshift32
	djnz rootDirSizeLoop
	;(hl) = size of root dir in bytes

	pop de ;fat_rootDirStartAddr
	call add32

	ld de, fat_sectorsPerCluster - (fat_dataStartAddr)
	add hl, de
	;hl = fat_sectorsPerCluster
	push hl

	push af
	push ix
	ld de, FAT_VBR_SECTORS_PER_CLUSTER
	ld h, K_SEEK_SET
	call k_seek
	pop ix
	pop af

	pop de ;fat_sectorsPerCluster
;	push af
;	push ix
	ld hl, 1
	call k_read
;	pop ix
;	pop af
	xor a

	ret
.endf
