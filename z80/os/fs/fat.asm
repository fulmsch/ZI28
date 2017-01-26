.list
fat_fsDriver:
	.dw fat_init
	.dw fat_open
	.dw 0000h     ;close

fat_fileDriver:
	.dw fat_read
	.dw fat_write
	.dw fat_seek
	.dw fat_fctl

.define fat_fileTableStartCluster fileTableData
.define fat_fileTableSize         fat_fileTableStartCluster + 2


fat_bootStartSector:    .resb 4

fat_vbr:
fat_oemName:            .resb 8
fat_bytesPerSector:     .resb 2
fat_sectorsPerCluster:  .resb 1
fat_reservedSectors:    .resb 2
fat_fatCopies:          .resb 1
fat_maxRootDirEntries:  .resb 2
fat_sectorsShort:       .resb 2
fat_mediaDescriptor:    .resb 1
fat_sectorsPerFat:      .resb 2
fat_sectorsPerTrack:    .resb 2
fat_heads:              .resb 2
fat_sectorsBeforeVBR:   .resb 4
fat_sectorsLong:        .resb 4
fat_driveNumber:        .resb 2
fat_bootRecordSig:      .resb 1
fat_serialNumber:       .resb 4

fat_fat1StartSector:    .resb 4
fat_fat2StartSector:    .resb 4

fat_rootDirStartSector: .resb 4
fat_dataStartSector:    .resb 4

; Calculate and store filesystem offsets
.func fat_init:
	;load the MBR
	xor a
	ld b, a
	ld c, a
	ld d, a
	ld e, a
	ld a, 1
	ld hl, sdBuffer
	rst sdRead
	;TODO add error

	;store partition start in memory
	ld hl, sdBuffer + 1c6h
	ld de, fat_bootStartSector
	ld bc, 4
	ldir

	;load volume boot record
	ld hl, sdBuffer + 1c6h
	call sectorToAddr

	ld a, 1
	ld hl, sdBuffer
	rst sdRead
	;TODO add error

	;store information about the fs in memory
	ld hl, sdBuffer + 3
	ld de, fat_vbr
	ld bc, 2ah
	ldir

	;TODO check the number of fat copies

	;calculate the sector of the first fat
	ld a, (fat_reservedSectors)
	ld hl, fat_bootStartSector
	ld de, fat_fat1StartSector

	add a, (hl)
	ld (de), a

	ld b, 3
	call addCarry

	;calculate the sector of the second fat
	ld hl, fat_fat1StartSector
	ld de, fat_fat2StartSector
	ld bc, fat_sectorsPerFat

	ld a, (bc)
	add a, (hl)
	ld (de), a
	inc hl
	inc de
	inc bc
	ld a, (bc)
	adc a, (hl)
	ld (de), a

	ld b, 2
	call addCarry


	;calculate the start of the root directory
	ld hl, fat_fat2StartSector
	ld de, fat_rootDirStartSector
	ld bc, fat_sectorsPerFat

	ld a, (bc)
	add a, (hl)
	ld (de), a
	inc hl
	inc de
	inc bc
	ld a, (bc)
	adc a, (hl)
	ld (de), a

	ld b, 2
	call addCarry

	;calculate the size of the root directory
	ld hl, (fat_maxRootDirEntries)
	xor a
	add hl, hl
	rla
	add hl, hl
	rla
	add hl, hl
	rla
	add hl, hl
	rla
	ld c, h
	ld b, a

	;calculate the start of the data region
	ld hl, fat_rootDirStartSector
	ld de, fat_dataStartSector
	ld a, (hl)
	add a, c
	ld (de), a
	inc hl
	inc de
	ld a, (hl)
	adc a, b
	ld (de), a

	ld b, 2
	call addCarry

	;close all open files
;	ld a, 0
	;ld (fileTableMap), a

	ret
.endf ;fat_init


;*****************
;Open file
;Description: creates a new file table entry
;Old Inputs: (de) = pathname, a = mode
;Inputs: ix = table entry, (de) = absolute path, a = mode
;Outputs: a = errno
;Errors: 0=no error
;        4=no matching file found
;        5=file too large
;Destroyed: all
.func fat_open:
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

;*****************
;Read from file
;Description: copy data from a file to memory
;Old Inputs: a = file descriptor, (de) = buffer, hl = count
;Inputs: ix = file entry addr, (de) = buffer, bc = count
;Outputs: a = errno, de = count
;Errors: 0=no error
;        1=invalid file descriptor
;Destroyed: none
.func fat_read:
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

.func fat_seek:

.endf ;fat_seek

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
;Add long numbers
;Description: add carry and (hl), stores it at (de), b times
;Inputs: number at (hl), b, carry
;Outputs: number at (de)
;Destroyed: a
addCarry:
	inc hl
	inc de
	ld a, 0
	adc a, (hl)
	ld (de), a
	djnz addCarry
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
	call strCompare
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
