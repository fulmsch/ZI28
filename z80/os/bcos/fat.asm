fat_bootStartSector:    ds 4

fat_vbr:
fat_oemName:            ds 8
fat_bytesPerSector:     ds 2
fat_sectorsPerCluster:  ds 1
fat_reservedSectors:    ds 2
fat_fatCopies:          ds 1
fat_maxDirsInRoot:      ds 2
fat_sectorsShort:       ds 2
fat_mediaDescriptor:    ds 1
fat_sectorsPerFAT:      ds 2
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

	;calculate partition start
	ld hl, sdBuffer + 1c6h
	call sectorToAddr
	;store partition start in memory
	ld hl, fat_bootStartSector
	ld (hl), b
	inc hl
	ld (hl), c
	inc hl
	ld (hl), d
	inc hl
	ld (hl), e

	ld a, 1
	ld hl, sdBuffer
	rst sdRead
	;store information about the fs in memory
	ld hl, sdBuffer + 3
	ld de, fat_vbr
	ld bc, 2ah
	ldir

	;calculate the address of the first fat
	ld hl, fat_bootStartSector
	ld de, fat_fat1StartSector
	ld a, (hl)
	ld (de), a
	inc hl
	inc de

	ld a, (fat_reservedSectors)
	rla
	add a, (hl)
	ld (de), a

	ld a, 0
	inc hl
	inc de
	adc a, (hl)
	ld (de), a
	ld a, 0
	inc hl
	inc de
	adc a, (hl)
	ld (de), a

	ret



;*****************
;SectorToAddressg
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
