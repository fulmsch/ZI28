fat_bootStartSector:    ds 4

fat_vbr:
fat_oemName:            ds 8
fat_bytesPerSector:     ds 2
fat_sectorsPerCluster:  ds 1
fat_reservedSectors:    ds 2
fat_fatCopies:          ds 1
fat_maxRootDirEntries:  ds 2
fat_sectorsShort:       ds 2
fat_mediaDescriptor:    ds 1
fat_sectorsPerFat:      ds 2
fat_sectorsPerTrack:    ds 2
fat_heads:              ds 2
fat_sectorsBeforeVBR:   ds 4
fat_sectorsLong:        ds 4
fat_driveNumber:        ds 2
fat_bootRecordSig:      ds 1
fat_serialNumber:       ds 4

fat_fat1StartSector:    ds 4
fat_fat2StartSector:    ds 4

fat_rootDirStartSector: ds 4
fat_dataStartSector:    ds 4

; Calculate and store filesystem offsets
initfs:
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

	ret



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
.clusterToSectorLoop:
	add hl, hl
	rla
	jr nc, $+4
	add hl, de
	adc a, c
	djnz .clusterToSectorLoop

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
;Outputs: directory entry at (ix)
;Destroyed: a, bc
findDirEntry:
	;TODO add capability to search sequential sectors
	push de
	ld de, .findDirEntrySector
	ld bc, 4
	ldir

	ld hl, .findDirEntrySector
	call sectorToAddr
	ld a, 1
	ld hl, sdBuffer
	rst sdRead
	;TODO add error

	ld hl, sdBuffer
	ld b, 16
.findDirEntryLoop:
	;cycle through entries
	ld a, (hl)
	cp 0
	jr z, .findDirEntryEnd;end of directory
	push hl
	ld de, .findDirEntryNameBuffer
	call buildFilenameString
	pop hl
	pop de
	push de
	push hl
	push bc
	ld hl, .findDirEntryNameBuffer
	call strCompare
	pop bc
	jr z, .findDirEntryMatch
	pop hl
	ld de, 32
	add hl, de
	djnz .findDirEntryLoop


.findDirEntryEnd:
	pop de ;clear the stack
	or 1 ;reset zero flag
	ret

.findDirEntryMatch:
	pop ix ;pointer to entry
	pop de ;clear the stack
	ret


.findDirEntrySector:
	ds 4
.findDirEntryNameBuffer:
	ds 13


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
.buildFilenameTerminateName:
	ld a, (de)
	cp ' '
	inc de
	jr nz, .buildFilenameTerminateName
	dec de

	;de now points to the char after the name, hl to the extension of the entry
	ld a, (hl)
	cp ' '
	jr z, .buildFilenameEnd
	ld a, '.'
	ld (de), a
	inc de

	ld b, 3
.buildFilenameExtension:
	ld a, (hl)
	cp ' '
	jr z, .buildFilenameEnd
	ld (de), a
	inc hl
	inc de
	djnz .buildFilenameExtension

.buildFilenameEnd:
	ld a, 0
	ld (de), a
	ret


;****************
;String Compare
;Description: Compares two strings
;Inputs: de, hl: String pointers
;Outputs: z if equal strings
;Destroyed: a, b
strCompare:
	ld a, (de)
	ld b, a
	ld a, (hl)
	cp b
	ret nz
	cp 00h
	ret z
	inc de
	inc hl
	jr strCompare
	
	
;*****************
;ConvertToUpper
;Description: Converts a string to uppercase
;Inputs: hl: String pointer
;Outputs:
;Destroyed: none
convertToUpper:
	ld a, (hl)
	cp 0
	ret z

	cp 61h
	jr c, .convertToUpper00
	cp 7bh
	jr nc, .convertToUpper00
	sub 20h
	ld (hl), a
.convertToUpper00:
	inc hl
	jr convertToUpper
