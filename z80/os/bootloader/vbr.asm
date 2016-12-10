;**************************
;FAT16 bootloader
;Florian Ulmschneider 2016

;Expected conditions:
;VBR-sector loaded at c200h

.z80
.include "biosCalls.h"

.define vbrLoadAddress 0c200h
.define bootloaderCode vbrLoadAddress+3eh
.define sdBuffer 4200h
.define loadAddress 5000h

.define fat_vbr               vbrLoadAddress
.define fat_oemName           fat_vbr+03h
.define fat_bytesPerSector    fat_vbr+0bh
.define fat_sectorsPerCluster fat_vbr+0dh
.define fat_reservedSectors   fat_vbr+0eh
.define fat_fatCopies         fat_vbr+10h
.define fat_maxRootDirEntries fat_vbr+11h
.define fat_sectorsShort      fat_vbr+13h
.define fat_mediaDescriptor   fat_vbr+15h
.define fat_sectorsPerFat     fat_vbr+16h
.define fat_sectorsPerTrack   fat_vbr+18h
.define fat_heads             fat_vbr+1ah
.define fat_sectorsBeforeVBR  fat_vbr+1ch
.define fat_sectorsLong       fat_vbr+20h
.define fat_driveNumber       fat_vbr+24h

.org vbrLoadAddress
	jr bootloaderStart
	nop

.binfile "fat.bin"
;	.resb bootloaderCode-$

;	org bootloaderCode

fat_rootDirStartSector: ds 4
fat_dataStartSector:    ds 4

readSector:
	.resb 4

bootDir:
	.asciiz "SYS        "
bootFile:
	.asciiz "BCOS    BIN"

bootloaderStart:
	ld sp, 8000h

	;store basic fs info
	;calculate the start of the root directory
	ld hl, (fat_sectorsPerFat)
	add hl, hl
	ld a, (fat_reservedSectors)
	ld c, a
	ld b, 0
	add hl, bc

	ex de, hl
	ld hl, (fat_sectorsBeforeVBR)
	add hl, de
	ld (fat_rootDirStartSector), hl
	ld hl, (fat_sectorsBeforeVBR+2)
	ld de, 0
	adc hl, de
	ld (fat_rootDirStartSector+2), hl


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
	ld hl, (fat_rootDirStartSector)
	add hl, bc
	ld (fat_dataStartSector), hl
	ld hl, (fat_rootDirStartSector+2)
	ld bc, 0
	adc hl, bc
	ld (fat_dataStartSector+2), hl

	;search the file
	ld de, bootDir
	ld hl, fat_rootDirStartSector
	call findDirEntry

	ld l, (ix+1ah)
	ld h, (ix+1bh)
	ld de, readSector
	call clusterToSector

	ld hl, readSector
	ld de, bootFile
	call findDirEntry

;*****************
;Read from file
;Description: copy data from a file to memory
;Inputs: a = file descriptor, (de) = buffer, hl = count
;Outputs: a = errno, de = count
;Errors: 0=no error
;        1=invalid file descriptor
;Destroyed: none
	;(ix)=file entry
	;TODO check filesize
	ld c, (ix+1ch)
	ld b, (ix+1dh)
	;bc=filesize

	push bc ;count
	;calculate starting sector
	ld l, (ix+1ah)
	ld h, (ix+1bh)
	ld de, readSector
	call clusterToSector

	;TODO count bytes
	pop de ;count
	push de
	
	;calculate the number of full sectors
	ld a, d
	srl a
	jr z, readLastSector ;less than a sector left

	;load full sectors directly
	ld hl, readSector
	call sectorToAddr
	ld hl, loadAddress
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

	;jump to loaded program
	jp 5000h



;*****************
;Find directory entry
;Description: search for the entry of a named file
;Inputs: directory sector at (hl), name string at (de)
;Outputs: directory entry at (ix)
;Destroyed: a, bc
findDirEntry:
	;TODO add capability to search sequential sectors
	push de ;name
	ld de, findDirEntrySector
	ld bc, 4
	ldir

	ld hl, findDirEntrySector
	call sectorToAddr
	ld a, 1
	ld hl, sdBuffer
	rst sdRead
	;TODO add error

	ld hl, sdBuffer
	ld b, 16
findDirEntryLoop:
	;cycle through entries
	ld a, (hl)
	cp 0
	jr z, findDirEntryEnd;end of directory
	pop de ;name
	push de ;name
	push hl ;start of entry
	push bc ;counter
	call strCompare
	pop bc ;counter
	jr z, findDirEntryMatch
	pop hl ;start of entry
	ld de, 32
	add hl, de
	djnz findDirEntryLoop


findDirEntryEnd:
	pop de ;clear the stack
	or 1 ;reset zero flag
	ret

findDirEntryMatch:
	pop ix ;pointer to entry
	pop de ;clear the stack
	ret


findDirEntrySector:
	.resb 4


;****************
;String Compare
;Description: Compares two strings
;Inputs: de, hl: String pointers
;Outputs: z if equal strings
;Destroyed: a, b
strCompare:
	ld a, (de)
	cp 00h
	ret z
	ld b, a
	ld a, (hl)
	cp 00h
	ret z
	cp b
	ret nz
	inc de
	inc hl
	jr strCompare


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
