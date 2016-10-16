.fileTableEntrySize: equ 32
.fileTableEntries: equ 8
fileTableMap:
	db 00h
fileTable:
	ds .fileTableEntrySize * .fileTableEntries

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
.tableSpot:
	db 0

.tableSpotFound:
	;remember spot for later
	ld a, 8
	sub b
	ld (.tableSpot), a

	;(de)=filename
	ld hl, fat_rootDirStartSector ;TODO resolve path so that only the filename is left
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
;Destroyed: none
_readFile:

