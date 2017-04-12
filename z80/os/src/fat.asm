;; FAT-16 file system
.list
;TODO move all variables to ram

fat_fsDriver:
	.dw fat_init
	.dw fat_open

.define fat_fat1StartSector    driveTableFsdata
.define fat_fat2StartSector    fat_fat1StartSector + 4
.define fat_rootDirStartSector fat_fat2StartSector + 4
.define fat_sectorsPerCluster  fat_rootDirStartSector + 4
.define fat_dataStartSector    fat_sectorsPerCluster + 1


fat_fileDriver:
	.dw fat_read
	.dw fat_write
;	.dw fat_fctl

.define fat_fileTableStartCluster fileTableData
.define fat_fileTableSize         fat_fileTableStartCluster + 2


;Boot sector contents             Offset|Length (in bytes)
.define FAT_VBR_OEM_NAME             03h ;8
.define FAT_VBR_BYTES_PER_SECTOR     0bh ;2
.define FAT_VBR_SECTORS_PER_CLUSTER  0dh ;1
.define FAT_VBR_RESERVED_SECTORS     0eh ;2
.define FAT_VBR_FAT_COPIES           10h ;1
.define FAT_VBR_MAX_ROOT_DIR_ENTRIES 11h ;2
.define FAT_VBR_SECTORS_SHORT        13h ;2
.define FAT_VBR_MEDIA_DESCRIPTOR     15h ;1
.define FAT_VBR_SECTORS_PER_FAT      16h ;2
.define FAT_VBR_SECTORS_PER_TRACK    18h ;2
.define FAT_VBR_HEADS                1ah ;4
.define FAT_VBR_SECTORS_BEFORE_VBR   1ch ;4
.define FAT_VBR_SECTORS_LONG         20h ;1
.define FAT_VBR_DRIVE_NUMBER         24h ;1
.define FAT_VBR_BOOT_RECORD_SIG      26h ;1
.define FAT_VBR_SERIAL_NUMBER        27h ;4


.func fat_init:
;; Calculate and store filesystem offsets
;;
;; Input:
;; : a - fd of device containing the fs

	;TODO store values in the actual drive table entry

	;Store the sector of the first FAT
	ld hl, fat_fat1StartSector
	call clear32

	push af
	ld de, FAT_VBR_RESERVED_SECTORS
	ld h, SEEK_SET
	call k_seek
	pop af

	push af
	ld de, fat_fat1StartSector
	ld hl, 1
	call k_read
	pop af


	;Calculate the sector of the second FAT
	ld hl, fat_fat1StartSector
	ld de, fat_fat2StartSector
	call ld32

	ld hl, reg32
	call clear32

	push af
	ld de, FAT_VBR_SECTORS_PER_FAT
	ld h, SEEK_SET
	call k_seek
	pop af

	push af
	ld de, reg32
	ld hl, 2
	call k_read
	pop af
	;(reg32) = sectors per fat

	ld hl, fat_fat2StartSector
	ld de, reg32
	call add32


	;Calculate the start of the root directory
	ld hl, fat_fat2StartSector
	ld de, fat_rootDirStartSector
	call ld32

	ex de, hl
	ld de, reg32
	call add32


	;Calculate the start of the data region
	ld hl, fat_rootDirStartSector
	ld de, fat_dataStartSector
	call ld32

	ld hl, reg32
	call clear32

	push af
	ld de, FAT_VBR_MAX_ROOT_DIR_ENTRIES
	ld h, SEEK_SET
	call k_seek
	pop af

	push af
	ld de, reg32
	ld hl, 2
	call k_read
	pop af

	;Calculate the length of the root dir
	;Length in sectors = n_entries * size of entry / size of sector
	;                  = n_entries * 32 / 512 = n_entries >> 4
	ld hl, reg32
	ld b, 4
rootDirSizeLoop:
	call rshift32
	djnz rootDirSizeLoop
	;(reg32) = size of root dir in sectors

	ld de, fat_dataStartSector
	ex de, hl
	call add32

	;close all open files
;	ld a, 0
	;ld (fileTableMap), a

	ret
.endf ;fat_init

.func fat_open:
;; Description: creates a new file table entry
;; Old Inputs: (de) = pathname, a = mode
;; Inputs: ix = table entry, (de) = absolute path, a = mode
;; Outputs: a = errno
;; Errors: 0=no error
;;         4=no matching file found
;;         5=file too large
;; Destroyed: all

;	ld (tableEntry), hl
	ld (mode), a

	ld hl, fat_rootDirStartSector ;path is relative to the root directory
	jr nextLevel

resolvePath:
	ld a, 0
	ld (bc), a
	push de
	;ld d, b
	;ld e, c
	ld de, pathBuffer
	call findDirEntry
	pop de
	ld a, 4
	ret nz
	push de
	;calculate start sector of subdirectory
	ld l, (iy+1ah)
	ld h, (iy+1bh)
	ld de, sector
	call clusterToSector

	pop de
	inc de
	ld hl, sector


nextLevel:
	;(de)=relative path, hl=directory sector
	;copy the next file/directory to a buffer
	ld bc, pathBuffer
pathLoop:
	ld a, (de)
	cp '/'
	jr z, resolvePath ;copied the entire folder name
	ld (bc), a
	inc bc
	inc de
	cp 0
	jr nz, pathLoop
	
	;reached the deepest level
	ld de, pathBuffer
	call findDirEntry
	ld a, 4
	ret nz ;no file found
	;TODO check filesize
	;(iy)=directory entry

;	ld ix, (tableEntry)
	;TODO check mode

	;populate table entry
;	push ix
;	push iy
;	pop de
;	pop hl
;	call buildFilenameString
	ld a, (iy + 0x0b)
	ld (ix + fileTableAttributes), a
	ld a, (iy + 1ah)
	ld (ix + fat_fileTableStartCluster), a
	ld a, (iy + 1bh)
	ld (ix + fat_fileTableStartCluster + 1), a
	ld a, (iy + 1ch)
	ld (ix + fat_fileTableSize), a
	ld a, (iy + 1dh)
	ld (ix + fat_fileTableSize + 1), a
;	;TODO depending on mode
;	xor a
;	ld (iy+fileTablePointer), a
;	ld (iy+fileTablePointer+1), a
	;TODO move to k_open
	ld a, (mode)
	ld (ix + fileTableMode), a

	ld hl, fat_fileDriver
	ld (ix + fileTableDriver), l
	ld (ix + fileTableDriver + 1), h

;	ld a, (driveNumber)
;	ld (iy + fileTableDrive), a

	;fill table spot
	ld (ix + 0), 01h

	;operation succesful
	xor a
	ret

;tableEntry:
;	.dw 0
mode:
	.db 0
pathBuffer:
	.resb 13
sector:
	.resb 4

.endf ;fat_open

.func fat_read:
;; Description: copy data from a file to memory
;; Old Inputs: a = file descriptor, (de) = buffer, hl = count
;; Inputs: ix = file entry addr, (de) = buffer, bc = count
;; Outputs: a = errno, de = count
;; Errors: 0=no error
;;         1=invalid file descriptor
;; Destroyed: none

	;(ix)=table entry
	;TODO check mode
	;TODO check filesize

	ld l, (ix+fat_fileTableSize)
	ld h, (ix+fat_fileTableSize+1)
	or a
	sbc hl, bc
	jr nc, readCluster

	ld c, (ix+fat_fileTableSize)
	ld b, (ix+fat_fileTableSize+1)

readCluster:
	push bc ;count
	push de ;buffer
	;calculate starting sector
	ld l, (ix+fat_fileTableStartCluster)
	ld h, (ix+fat_fileTableStartCluster+1)
	ld de, readSector
	call clusterToSector

	;TODO count bytes
	pop hl ;buffer
	pop de ;count
	push de
	
	;calculate the number of full sectors
	ld a, d
	srl a
	push hl ;buffer
	jr z, readLastSector ;less than a sector left


	;load full sectors directly
	ld hl, readSector
	call sectorToAddr
	pop hl ;buffer
	push af ;amount of full sectors to be read
	rst sdRead
	;TODO add error

	pop af ;count of read sectors
	push hl ;buffer

	ld hl, readSector
	add a, (hl)
	ld (hl), a
	ld b, 3
readAddSectorsLoop:
	inc hl
	ld a, 0
	adc a, (hl)
	ld (hl), a
	djnz readAddSectorsLoop

readLastSector:
	;load last sector into sdBuffer
	ld hl, readSector
	call sectorToAddr
	ld hl, sdBuffer
	ld a, 1
	rst sdRead
	;TODO add error

	;copy the remaining bytes into memory
	pop de
	pop bc
	ld a, b
	and 1
	ld b, a

	ld hl, sdBuffer
	ldir

	ld a, 0
	ret

tableEntry:
	.dw 0
;buffer:
;	.dw 0
count:
	.dw 0
readSector:
	.resb 4

.endf ;fat_read

.func fat_write:

.endf ;fat_write

.func fat_fctl:

.endf ;fat_fctl

;*****************
;SectorToAddress
;Description: converts a sd-card sector to an address
;Inputs: sector at hl
;Outputs: address in bcde
;Destroyed: none
sectorToAddr:
	ld b, 0
	ld c, (hl)
	inc hl
	ld d, (hl)
	inc hl
	ld e, (hl)
	sla c
	rl d
	rl e
	ret


;*****************
;Cluster to sector
;Description: converts a cluster to a sector
;Inputs: cluster in hl, buffer at de
;Outputs:
;Destroyed: a, bc
clusterToSector:
	or a ;clear carry flag
	ld bc, 2
	sbc hl, bc ;get real cluster offset
	;multiply by the number of sectors per cluster
	push de
	ex de, hl
	ld a, (fat_sectorsPerCluster)
	;multiply de by a, result in ahl
	;rountine from http://wikiti.brandonw.net/index.php?title=Z80_Routines:Math:Multiplication
	ld c, 0
	ld h, c
	ld l, h

	add a, a ; optimised 1st iteration
	jr nc, $+4
	ld h,d
	ld l,e

	ld b, 7
clusterToSectorLoop:
	add hl, hl
	rla
	jr nc, $+4
	add hl, de
	adc a, c
	djnz clusterToSectorLoop

	;ahl=sector offset
	pop de
	push af
	ld bc, fat_dataStartSector
	ld a, (bc)
	add a, l
	ld (de), a
	inc bc
	inc de
	ld a, (bc)
	adc a, h
	ld (de), a
	inc bc
	inc de
	pop hl
	ld a, (bc)
	adc a, h
	ld (de), a
	ld a, (bc)
	adc a, 0
	ld (de), a

	ret

;*****************
;Find directory entry
;Description: search for the entry of a named file
;Inputs: directory sector at (hl), name string at (de)
;Outputs: directory entry at (iy)
;Destroyed: a, bc
.func findDirEntry:
	;TODO add capability to search sequential sectors
	push de
	ld de, entrySector
	ld bc, 4
	ldir

	ld hl, entrySector
	call sectorToAddr
	ld a, 1
	ld hl, sdBuffer
	rst sdRead
	;TODO add error

	ld hl, sdBuffer
	ld b, 16
entryLoop:
	;cycle through entries
	ld a, (hl)
	cp 0
	jr z, entryEnd;end of directory
	push hl
	ld de, entryNameBuffer
	call buildFilenameString
	pop hl
	pop de
	push de
	push hl
	push bc
	ld hl, entryNameBuffer
	call strcmp
	pop bc
	jr z, entryMatch
	pop hl
	ld de, 32
	add hl, de
	djnz entryLoop


entryEnd:
	pop de ;clear the stack
	or 1 ;reset zero flag
	ret

entryMatch:
	pop iy ;pointer to entry
	pop de ;clear the stack
	ret


entrySector:
	.ds 4
entryNameBuffer:
	.ds 13
.endf ;findDirEntry


;*****************
;Build filename string
;Description: creates a 8.3 string from a directory entry
;Inputs: dir entry at (hl)
;Outputs: 8.3 filename string at (de)
;Destroyed: a, bc
buildFilenameString:
	push de
	;copy the first 8 chars of the dir entry
	ld bc, 8
	ldir
	ld a, ' '
	ld (de), a

	pop de
buildFilenameTerminateName:
	ld a, (de)
	cp ' '
	inc de
	jr nz, buildFilenameTerminateName
	dec de

	;de now points to the char after the name, hl to the extension of the entry
	ld a, (hl)
	cp ' '
	jr z, buildFilenameEnd
	ld a, '.'
	ld (de), a
	inc de

	ld b, 3
buildFilenameExtension:
	ld a, (hl)
	cp ' '
	jr z, buildFilenameEnd
	ld (de), a
	inc hl
	inc de
	djnz buildFilenameExtension

buildFilenameEnd:
	ld a, 0
	ld (de), a
	ret
