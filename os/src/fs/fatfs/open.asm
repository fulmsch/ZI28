.list

.func fat_open:
;; Creates a new file table entry
;;
;; Input:
;; : ix - table entry
;; : (de) - absolute path
;;
;; Output:
;; : a - errno

; Errors: 0=no error
;         4=no matching file found
;         5=file too large
; Destroyed: all

	ld (fat_open_path), de

	;get the drive table entry of the filesystem
	ld a, (ix + fileTableDriveNumber)
	call getDriveAddr
	jp c, error ;drive number out of bounds
	push hl
	pop iy
	;iy = table entry address

	;open the root directory
	;populate: driver, size, startcluster, dir entry address, type
	;size = dataStart - rootDirStart
	ld b, ixh
	ld c, ixl
	ld hl, fileTableDriver
	add hl, bc
	ld (hl), fat_fileDriver & 0xff
	inc hl
	ld (hl), fat_fileDriver >> 8

	ld bc, 6 ;fileTableSize - (fileTableDriver + 1)
	add hl, bc
	ex de, hl
	;(de) = size

	ld b, iyh
	ld c, iyl
	ld hl, fat_dataStartAddr
	add hl, bc
	;(hl) = dataStart

	call ld32 ;size = dataStart

	ld bc, fat_dataStartAddr - (fat_rootDirStartAddr)
	add hl, bc
	;(de) = size, (hl) = rootDirStart
	call sub32 ;size = dataStart - rootDirStart = rootDirSize

	;clear dirEntryAddr
	ld hl, fat_fileTableDirEntryAddr - (fileTableSize)
	add hl, de
	call clear32

	;set mode to dir
	ld a, (ix + fileTableMode)
	or M_DIR
	ld (ix + fileTableMode), a

	;set startCluster to 0 to indicate the rootDir
	xor a
	ld (ix + fat_fileTableStartCluster), a
	ld (ix + fat_fileTableStartCluster + 1), a

	ld hl, (fat_open_path)
	;a = 0
	cp (hl)
	jr nz, openFile

	;root directory was requested
	xor a
	ret


openFile:
	ld de, fat_open_pathBuffer1
	;hl = (fat_open_path)
	ld b, 13
copyFilenameLoop:
	ld a, (hl)
	cp '/'
	jr z, copyFilenameCont
	cp 0x00
	jr z, copyFilenameCont
	ld (de), a
	inc de
	inc hl
	djnz copyFilenameLoop
	jp error ;filename too long

copyFilenameCont:
	xor a
	ld (de), a
	;(hl) = '/' or 0x00
	ld (fat_open_path), hl

compareLoop:
	ld de, fat_dirEntryBuffer
	ld bc, 32 ;count
	push ix
	push iy
	call fat_read
	pop iy
	pop ix

	;add count to offset
	ld hl, regA
	call ld16 ;load count into regA
	ld d, h
	ld e, l

	ld b, ixh
	ld c, ixl
	ld hl, fileTableOffset
	add hl, bc
	call add32

	;TODO check for EOF
	ld hl, fat_dirEntryBuffer
	ld a, (hl)
	cp 0x00 ;end of dir reached, no match
	jp z, error
	cp 0xe5 ;deleted file
	jr z, compareLoop

	;generate filename in pathBuffer2
	ld de, fat_open_pathBuffer2
	push de
	call fat_buildFilename
	pop de

	;compare buffer 1 and 2
	ld b, 13
	ld hl, fat_open_pathBuffer1
	call strncmp
	jr nz, compareLoop

match:
	;open the found file
	;populate: offset, size, startcluster, dirEntryAddr

	;set dirEntryAddr to current offset of underlying device
	ld a, (iy + driveTableDevfd)
	ld de, 0
	ld h, K_SEEK_PCUR
	push ix
	push iy
	call k_seek
	pop iy
	pop ix
	;(de) = offset

	ld b, ixh
	ld c, ixl
	ld hl, fat_fileTableDirEntryAddr
	add hl, bc
	ex de, hl
	call ld32
	;(de) = dirEntryAddr + 32
	ld a, 32
	ld hl, regA
	call ld8
	call sub32


	;set offset to 0
	ld b, ixh
	ld c, ixl
	ld hl, fileTableOffset
	add hl, bc
	call clear32

	ld bc, fileTableSize - (fileTableOffset)
	add hl, bc

	ex de, hl
	;(de) = fileTableSize
	ld hl, fat_dirEntryBuffer + 0x1c
	call ld32

	ld a, (fat_dirEntryBuffer + 0x1a)
	ld (ix + fat_fileTableStartCluster), a
	ld a, (fat_dirEntryBuffer + 0x1a + 1)
	ld (ix + fat_fileTableStartCluster + 1), a


	ld hl, (fat_open_path)
	xor a
	cp (hl)
	jr z, finish

	inc hl
	cp (hl)
	jr z, dirFinish
	ld (fat_open_path), hl

	;to continue, file must be a directory
	ld a, (fat_dirEntryBuffer + 0x0b) ;attributes
	and 1 << FAT_ATTRIB_DIR
	jr z, error ;not a directory
	;TODO possibly optimize these jumps
	jp openFile

dirFinish:
	;path ended in '/', must be a directory
	ld a, (fat_dirEntryBuffer + 0x0b) ;attributes
	and 1 << FAT_ATTRIB_DIR
	jr z, error ;not a directory

finish:
	;check permission
	ld a, (fat_dirEntryBuffer + 0x0b) ;attributes
	ld b, (ix + fileTableMode)
	res M_DIR_BIT, b
	bit M_WRITE_BIT, b
	jr z, fileType
	bit FAT_ATTRIB_RDONLY, a
	jr nz, error ;write requested, file is read only

fileType:
	;a = file attributes, b = mode

	and 1 << FAT_ATTRIB_DIR
	ld a, M_REG
	jr z, fileMode ;regular file
	ld a, M_DIR

fileMode:
	;a = file type, b = mode
	or b
	ld (ix + fileTableMode), a
	xor a
	ret

error:
	ld a, 1
	ret
.endf
