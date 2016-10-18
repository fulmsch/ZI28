.fileTableEntrySize: equ 32
.fileTableEntries: equ 8
fileTableMap:
	db 00h
fileTable:
	ds .fileTableEntrySize * .fileTableEntries

.tableSpot:
	db 0

fileTableName:         equ 0
fileTableAttributes:   equ fileTableName + 13
fileTableStartCluster: equ fileTableAttributes + 1
fileTableSize:         equ fileTableStartCluster + 2
fileTablePointer:      equ fileTableSize + 2
fileTableMode:         equ fileTablePointer + 2

;*****************
;Open file
;Description: creates a new file table entry
;Inputs: (de) = pathname , a = mode
;Outputs: e = file descriptor, a = errno
;Errors: 0=no error
;        1=maximum allowed files already open
;        2=no matching file found
;        3=file too large
;Destroyed: all
_openFile:
	ld (.openFileMode), a
	;search free table spot
	ld a, (fileTableMap)
	ld b, 8
.tableSearchLoop:
	srl a
	jr nc, .tableSpotFound
	djnz .tableSearchLoop

	;no free spot found, return error
	ld a, 1
	ret

.openFileMode:
	db 0
.openFilePathBuffer:
	ds 13
.openSector:
	ds 4

.openResolvePath:
	ld a, 0
	ld (bc), a
	push de
	;ld d, b
	;ld e, c
	ld de, .openFilePathBuffer
	call findDirEntry
	pop de
	ld a, 2
	ret nz
	push de
	;calculate start sector of subdirectory
	ld l, (ix+1ah)
	ld h, (ix+1bh)
	ld de, .openSector
	call clusterToSector

	pop de
	inc de
	ld hl, .openSector
	jr .openRelativePath

.tableSpotFound:
	;remember spot for later
	ld a, 8
	sub b
	ld (.tableSpot), a

	;(de)=filename
	ld hl, fat_rootDirStartSector ;TODO load the path of the active program here
	ld a, (de)
	cp '/'
	jr nz, .openRelativePath
	inc de
	ld hl, fat_rootDirStartSector ;path is relative to the root directory

.openRelativePath: ;TODO rename this label
	;(de)=relative path, hl=directory sector
	;copy the next file/directory to a buffer
	ld bc, .openFilePathBuffer
.openRelativeLoop:
	ld a, (de)
	cp '/'
	jr z, .openResolvePath ;copied the entire folder name
	ld (bc), a
	inc bc
	inc de
	cp 0
	jr nz, .openRelativeLoop
	
	;reached the deepest level
	ld de, .openFilePathBuffer
	call findDirEntry
	ld a, 2
	ret nz ;no file found
	;TODO check filesize
	;(ix)=directory entry
	ld a, (.tableSpot)
	add a, a
	add a, a
	add a, a
	add a, a
	add a, a
	ld b, 0
	ld c, a
	ld iy, fileTable
	add iy, bc
	;(iy)=table entry
	;TODO check mode

	;populate table entry
	push ix
	push iy
	pop de
	pop hl
	call buildFilenameString
	ld a, (ix+0bh)
	ld (iy+fileTableAttributes), a
	ld a, (ix+1ah)
	ld (iy+fileTableStartCluster), a
	ld a, (ix+1bh)
	ld (iy+fileTableStartCluster+1), a
	ld a, (ix+1ch)
	ld (iy+fileTableSize), a
	ld a, (ix+1dh)
	ld (iy+fileTableSize+1), a
	;TODO depending on mode
	xor a
	ld (iy+fileTablePointer), a
	ld (iy+fileTablePointer+1), a
	ld a, (.openFileMode)
	ld (iy+fileTableMode), a

	;fill table spot
	ld a, (.tableSpot)
	ld e, a ;return value
	ld b, a
	inc b
	xor a
	scf
.openFillTableSpot:
	rla
	djnz .openFillTableSpot

	ld hl, fileTableMap
	or (hl)
	ld (hl), a

	;operation succesful
	xor a
	ret

;*****************
;Close file
;Description: close a file table entry
;Inputs: a = file descriptor
;Outputs: a = errno
;Destroyed: none
_closeFile:


;*****************
;Read from file
;Description: copy data from a file to memory
;Inputs: a = file descriptor, (de) = buffer, hl = count
;Outputs: a = errno, de = count
;Errors: 0=no error
;        1=invalid file descriptor
;Destroyed: none
_readFile:
	;check if fd exists
	ld (.tableSpot), a
	ld b, a
	inc b
	ld a, (fileTableMap)
.readCheckTableSpot:
	srl a
	djnz .readCheckTableSpot

	ld a, 1
	ret nc

	ld a, (.tableSpot)
	add a, a
	add a, a
	add a, a
	add a, a
	add a, a
	ld b, 0
	ld c, a
	ld iy, fileTable
	add iy, bc
	;(iy)=table entry
	;TODO check mode
	;TODO check filesize

	push hl ;count
	push de ;buffer
	;calculate starting sector
	ld l, (iy+fileTableStartCluster)
	ld h, (iy+fileTableStartCluster+1)
	ld de, .readSector
	call clusterToSector

	;TODO count bytes
	pop hl ;buffer
	pop de ;count
	push de
	
	;calculate the number of full sectors
	ld a, d
	srl a
	push hl ;buffer
	jr z, .readLastSector ;less than a sector left


	;load full sectors directly
	ld hl, .readSector
	call sectorToAddr
	pop hl ;buffer
	push af ;amount of full sectors to be read
	rst sdRead
	;TODO add error

	pop af ;count of read sectors
	push hl ;buffer

	ld hl, .readSector
	add a, (hl)
	ld (hl), a
	ld b, 3
.readAddSectorsLoop:
	inc hl
	ld a, 0
	adc a, (hl)
	ld (hl), a
	djnz .readAddSectorsLoop

.readLastSector:
	;load last sector into sdBuffer
	ld hl, .readSector
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
	

.readSector:
	ds 4
