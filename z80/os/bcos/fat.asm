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
	call .addCarry

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
	call .addCarry


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
	call .addCarry

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
	call .addCarry


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
;Add long numbers
;Description: add carry and (hl), stores it in (de), b times
;Inputs: number in (hl), b, carry
;Outputs: number in (de)
;Destroyed: a
.addCarry:
	inc hl
	inc de
	ld a, 0
	adc a, (hl)
	ld (de), a
	djnz .addCarry
	ret
