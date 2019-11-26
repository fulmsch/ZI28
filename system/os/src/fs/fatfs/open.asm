#code ROM

fat_open:
;; Creates a new file table entry
;;
;; Input:
;; : ix - table entry
;; : (de) - absolute path
;; : a - flags
;;
;; Output:
;; : a - errno

; Errors: 0=no error
;         4=no matching file found
;         5=file too large
; Destroyed: all

#local
	ld (fat_open_path), de
	ld (fat_open_originalPath), de
	ld (fat_open_flags), a

	;get the drive table entry of the filesystem
	ld a, (ix + fileTableDriveNumber)
	ld h, 0 + (driveTable >> 8)
	ld l, a
	;hl = drive entry
	push hl
	pop iy
	;iy = table entry address

rootDir:
	;open the root directory
	;populate: driver, offset, size, startcluster, dir entry address, type
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
	;hl = (fat_open_path)
	ld de, fat_open_filenameBuffer
	call fat_build83Filename
	jp c, error
	;(hl) = '/' or 0x00
	ld (fat_open_path), hl
	ld a, 0x01 ;indicates no value
	ld (fat_open_freeEntry), a

compareLoop:
	ld de, fat_dirEntryBuffer
	ld bc, 32 ;count
	push ix
	push iy
	call fat_read
	;TODO add error checking
	pop iy
	pop ix

	ld hl, regA
	call ld16 ;load count into regA for later

	;TODO check for EOF
	ld a, (fat_dirEntryBuffer)
	cp 0x00 ;end of dir reached, no match
	jp z, noMatch
	cp 0xe5 ;deleted file
	jr nz, compareName

	ld de, fat_open_freeEntry
	ld a, (de)
	cp 0x01
	jr nz, compareName

	ld b, ixh
	ld c, ixl
	ld hl, fileTableOffset
	add hl, bc
	call ld32

compareName:
	;add count to offset
	ld de, regA
	ld b, ixh
	ld c, ixl
	ld hl, fileTableOffset
	add hl, bc
	call add32

	;compare buffer and dir entry
	ld b, 11
	ld hl, fat_dirEntryBuffer
	ld de, fat_open_filenameBuffer
	call memcmp
	jr nz, compareLoop

match:
	;open the found file
	;populate: offset, size, startcluster, dirEntryAddr

	;set dirEntryAddr to current offset of underlying device
	ld a, (iy + driveTableDevfd)
	ld de, 0
	ld h, SEEK_CUR ;TODO replace with CUR -32 and remove the subtraction further down
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
	jp z, error ;not a directory
	;TODO possibly optimize these jumps
	jp openFile

dirFinish:
	;path ended in '/', must be a directory
	ld a, (fat_dirEntryBuffer + 0x0b) ;attributes
	and 1 << FAT_ATTRIB_DIR
	jp z, error ;not a directory

finish:
	;check permission
	ld a, (fat_dirEntryBuffer + 0x0b) ;attributes
	ld b, (ix + fileTableMode)
	res M_DIR_BIT, b
	bit M_WRITE_BIT, b
	jr z, fileType
	bit FAT_ATTRIB_RDONLY, a
	jp nz, error ;write requested, file is read only

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

noMatch:
	ld hl, (fat_open_path)
	ld a, (hl)
	cp 0x00
	jr nz, error

	ld a, (fat_open_flags)
	bit O_CREAT_BIT, a
	jr z, error

	;create new file
	ld hl, fat_open_filenameBuffer
	ld de, fat_dirEntryBuffer
	ld bc, 11
	ldir

	ld h, d
	ld l, e
	inc de
	ld (hl), 0
	ld bc, 31 - 11
	ldir

	;write dir entry to disk
	ld bc, 33
	ld a, (fat_open_freeEntry)
	cp 0x01
	jr z, writeDirEntry
	dec bc
	;set offset to first free entry
	ld d, ixh
	ld e, ixl
	ld hl, fileTableOffset
	add hl, de
	ex de, hl
	ld hl, fat_open_freeEntry
	call ld32

writeDirEntry:
	ld de, fat_dirEntryBuffer
	push iy
	push ix
	call fat_write
	pop ix
	pop iy
	ld de, (fat_open_originalPath)
	ld (fat_open_path), de
	xor a
	ld (ix + fileTableOffset + 0), a
	ld (ix + fileTableOffset + 1), a
	ld (ix + fileTableOffset + 2), a
	ld (ix + fileTableOffset + 3), a
	jp rootDir ;TODO this is just a temporary hack

error:
	ld a, 1
	ret
#endlocal

#data RAM
fat_open_path:           defs  2
fat_open_originalPath:   defs  2
fat_open_flags:          defs  1
fat_open_freeEntry:      defs  4
fat_open_filenameBuffer: defs 11
