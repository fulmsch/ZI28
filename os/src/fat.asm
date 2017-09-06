;; FAT-16 file system
.list

fat_fsDriver:
	.dw fat_init
	.dw fat_open
	.dw fat_close
	.dw fat_readdir
	.dw fat_fstat

;drive table
.define fat_fat1StartAddr     driveTableFsdata          ;4 bytes
.define fat_fat2StartAddr     fat_fat1StartAddr + 4     ;4 bytes
.define fat_rootDirStartAddr  fat_fat2StartAddr + 4     ;4 bytes
.define fat_dataStartAddr     fat_rootDirStartAddr + 4  ;4 bytes
.define fat_sectorsPerCluster fat_dataStartAddr + 4     ;1 byte
                                                 ;Total 17 bytes

fat_fileDriver:
	.dw fat_read
	.dw fat_write

.define fat_fileTableStartCluster fileTableData                 ;2 bytes
.define fat_fileTableDirEntryAddr fat_fileTableStartCluster + 2 ;4 bytes

;file attributes
.define FAT_ATTRIB_RDONLY  0
.define FAT_ATTRIB_HIDDEN  1
.define FAT_ATTRIB_SYSTEM  2
.define FAT_ATTRIB_VOLLBL  3
.define FAT_ATTRIB_DIR     4
.define FAT_ATTRIB_ARCHIVE 5
.define FAT_ATTRIB_DEVICE  6


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
;;; : a - fd of device containing the fs
;; : ix - drive table entry address

	;TODO fix this crap


	;Store the sector of the first FAT
	ld d, ixh
	ld e, ixl
	ld hl, fat_fat1StartAddr
	add hl, de
	push hl ;fat1StarAddr
	call clear32

	ld a, (ix + driveTableDevfd)
	push af
	push ix
	ld de, FAT_VBR_RESERVED_SECTORS
	ld h, K_SEEK_SET
	call k_seek
	pop ix
	pop af

	pop de ;fat1StarAddr
	push de
	push af
	push ix
	ld hl, 1
	call k_read
	pop ix
	pop af

	pop hl ;fat1StartAddr
	call lshift9_32

	;Calculate the sector of the second FAT
	ld d, h
	ld e, l
	ld bc, fat_fat2StartAddr - (fat_fat1StartAddr)
	add hl, bc
	call clear32
	push de ;fat_fat1StartAddr
	push hl ;fat_fat2StartAddr

	push af
	push ix
	ld de, FAT_VBR_SECTORS_PER_FAT
	ld h, K_SEEK_SET
	call k_seek
	pop ix
	pop af

	pop de ;fat_fat2StartAddr
	push de

	push af
	push ix
	ld hl, 2
	call k_read
	pop ix
	pop af

	pop hl ;fat2StartAddr
	call lshift9_32
	;(fat_fat2StartAddr) = bytes per fat

	ld d, h
	ld e, l
	ld bc, fat_rootDirStartAddr - (fat_fat2StartAddr)
	add hl, bc
	ex de, hl
	;hl = fat_fat2StartAddr
	;de = fat_rootDirStartAddr
	call ld32
	ld b, d
	ld c, e

	pop de ;fat_fat1StartAddr
	call add32 ;fat2StartAddr = bytes_per_fat + fat1StartAddr
	ex de, hl ;de = fat2StartAddr
	ld h, b
	ld l, c
	call add32 ;rootDirStartAddr = bytes_per_fat + fat2StartAddr
	push hl ;rootDirStartAddr


	;Calculate the start of the data region
	;hl = fat_rootDirStartAddr
	ld de, fat_dataStartAddr - (fat_rootDirStartAddr)
	add hl, de
	;hl = fat_dataStartAddr
	call clear32
	push hl ;fat_dataStartAddr

	push af
	push ix
	ld de, FAT_VBR_MAX_ROOT_DIR_ENTRIES
	ld h, K_SEEK_SET
	call k_seek
	pop ix
	pop af

	pop de ;fat_dataStartAddr
	push de
	push af
	push ix
	ld hl, 2
	call k_read
	pop ix
	pop af

	;Calculate the length of the root dir
	;Length in sectors = n_entries * size of entry
	;                  = n_entries * 32 = n_entries << 5
	pop hl
	ld b, 5
rootDirSizeLoop:
	call lshift32
	djnz rootDirSizeLoop
	;(hl) = size of root dir in bytes

	pop de ;fat_rootDirStartAddr
	call add32

	ld de, fat_sectorsPerCluster - (fat_dataStartAddr)
	add hl, de
	;hl = fat_sectorsPerCluster
	push hl

	push af
	push ix
	ld de, FAT_VBR_SECTORS_PER_CLUSTER
	ld h, K_SEEK_SET
	call k_seek
	pop ix
	pop af

	pop de ;fat_sectorsPerCluster
;	push af
;	push ix
	ld hl, 1
	call k_read
;	pop ix
;	pop af
	xor a

	ret
.endf

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

.func fat_close:

	ret
.endf

.func fat_readdir:
;; Get information about the next file in a directory.
;;
;; Input:
;; : a - dirfd
;; : (de) - stat
;;
;; Output:
;; : a - errno

	push de
	push af

readLoop:
	pop af
	push af
	ld de, fat_dirEntryBuffer
	ld hl, 32
	push de
	call k_read
	pop hl

	;TODO check for EOF
	;hl = fat_dirEntryBuffer
	ld a, (hl)
	cp 0x00 ;end of dir reached, no match
	jp z, error
	cp 0x2e ;dot entry (. or ..), gets ignored
	jr z, readLoop
	cp 0xe5 ;deleted file
	jr z, readLoop
	cp 0x20 ;empty filename
	jr z, readLoop

	pop af
	pop de
	jp fat_statFromEntry



error:
	pop af
	pop de
	ld a, 1
	ret
.endf

.func fat_fstat:
;; Get information about a file.
;;
;; Input:
;; : ix - file entry addr
;; : (de) - stat
;;
;; Output:
;; : a - errno


	push de
	ld l, (ix + fat_fileTableStartCluster)
	ld h, (ix + fat_fileTableStartCluster + 1)
	ld de, 0
	or a
	sbc hl, de
	jr z, rootDir
	ld a, (ix + fileTableDriveNumber)
	call getDriveAddr
	jp c, error ;drive number out of bounds
	;hl = drive entry

	ld bc, driveTableDevfd
	add hl, bc
	ld a, (hl) ;a = devfd

	ld d, ixh
	ld e, ixl
	ld hl, fat_fileTableDirEntryAddr
	add hl, de
	ex de, hl ;(de) = dir entry addr

	ld h, K_SEEK_SET
	push af
	call k_lseek
	pop af
	;TODO error handling
	
	;load the directory entry
	ld de, fat_dirEntryBuffer
	ld hl, 32
	call k_read
	;TODO error handling
	pop de
	jp fat_statFromEntry

rootDir:
	pop de
	xor a
	ld (de), a ;name = null
	ld hl, STAT_ATTRIB
	add hl, de ;(hl) = stat attrib
	;TODO permission of drive
	ld (hl), ST_DIR | SP_WRITE | SP_READ
	;a = 0
	ret

error:
	pop de
	ld a, 1
	ret
.endf

.func fat_statFromEntry:
;; Creates a stat from a directory entry.
;;
;; Input:
;; : (de) - stat
	
	ld hl, fat_dirEntryBuffer
	;(de) = stat
	push de
	call fat_buildFilename
	pop de

	ld hl, fat_dirEntryBuffer + 0x0b ;attributes
	ld b, (hl)
	ld hl, STAT_ATTRIB
	add hl, de ;(hl) = stat attrib

	ld a, SP_READ
	bit FAT_ATTRIB_RDONLY, b
	jr nz, skipWrite
	or SP_WRITE
skipWrite:
	bit FAT_ATTRIB_DIR, b
	jr nz, dir
	or ST_REG
	jr writeAttrib
dir:
	or ST_DIR
writeAttrib:
	ld (hl), a

	ld bc, STAT_SIZE - (STAT_ATTRIB)
	add hl, bc
	ex de, hl ;(de) = stat size
	ld hl, fat_dirEntryBuffer + 0x1c ;size
	call ld32
	xor a
	ret
.endf

.func fat_read:
;; Copy data from a file to memory
;;
;; Input:
;; : ix - file entry addr
;; : (de) - buffer
;; : bc - count
;;
;; Output:
;; : a - errno
;; : de - count

; Errors: 0=no error
;         1=invalid file descriptor

	;******************************************;
	;                                          ;
	;  TODO test and debug multi-cluster read  ;
	;                                          ;
	;******************************************;

	ld (fat_rw_remCount), bc
	ld (fat_rw_dest), de
	ld de, 0
	ld (fat_rw_totalCount), de

	;get the drive table entry of the filesystem for clustersize, devfd, etc.
	ld a, (ix + fileTableDriveNumber)
	call getDriveAddr
	jp c, error ;drive number out of bounds
	push hl
	pop iy
	;iy = table entry address

	ld a, (ix + fileTableMode)
	bit M_DIR_BIT, a
	jr nz, isDir

	;regular file -> limit remCount to file size
	;return de=0 if offset >= filesize

	;add count to offset
	ld de, (fat_rw_remCount)
	ld hl, regA
	call ld16

	ld d, ixh
	ld e, ixl
	ld hl, fileTableSize
	add hl, de
	push hl ;size
	ld de, fileTableOffset-(fileTableSize)
	add hl, de
	push hl ;offset
	ex de, hl ;(de) = offset
	ld hl, regA
	call add32 ;regA = offset+count
	;if (regA > size) count = size - offset
	;c - hl > de
	;de - size
	;hl - regA
	pop bc ;offset
	pop de ;size
	push de ;size
	push bc ;offset
	call cp32
	pop bc ;offset
	pop hl ;size
	jr nc, notRootDir ;count does not need to be limited

	;limit count to size - offset or 0xffff
	;(de) = (de) - (hl)
	;de = size->regA
	;hl = offset
	ld de, regA
	call ld32 ;regA = size
	ld h, b
	ld l, c
	call sub32 ;regA = size - offset

.define ZERO_FLAG_BIT     0
.define OVERFLOW_FLAG_BIT 1

	ld b, 1 << ZERO_FLAG_BIT
	ld a, (de)
	ld l, a
	cp 0
	jr z, limitCount0
	res ZERO_FLAG_BIT, b
limitCount0:
	inc de
	ld a, (de)
	ld h, a
	cp 0
	jr z, limitCount1
	res ZERO_FLAG_BIT, b
limitCount1:
	inc de
	ld a, (de)
	cp 0
	jr z, limitCount2
	set OVERFLOW_FLAG_BIT, b
limitCount2:
	inc de
	ld a, (de)
	cp 0
	jr z, limitCount3
	set OVERFLOW_FLAG_BIT, b
	bit 0, a
	jr nz, zeroCount
limitCount3:
	bit OVERFLOW_FLAG_BIT, b
	jr nz, limitCount4
	bit ZERO_FLAG_BIT, b
	jr nz, zeroCount

	ld (fat_rw_remCount), hl
	jr notRootDir

limitCount4:
	ld hl, 0xffff
	ld (fat_rw_remCount), hl
	jr notRootDir


zeroCount:
	xor a
	ld d, a
	ld e, a
	ret


isDir:
	;check if root dir (cluster = 0)
	xor a
	ld b, (ix + fat_fileTableStartCluster)
	cp b
	jr nz, notRootDir
	ld b, (ix + fat_fileTableStartCluster + 1)
	cp b
	jp z, rootDir

notRootDir:
	ld a, (iy + fat_sectorsPerCluster)
	ld h, a
	sla h
	ld l, 0
	ld (fat_rw_clusterSize), hl

	;calculate the starting cluster of the read
	;a = sectorsPerCluster
	ld hl, fileTableOffset
	ld d, ixh
	ld e, ixl
	add hl, de
	ld de, regA
	call ld32

	ex de, hl
	call rshiftbyte32
clusterIndexLoop:
	call rshift32
	srl a
	jr nc, clusterIndexLoop

	;(regA) = index of cluster in chain (16-bit)

	ld e, (ix + fat_fileTableStartCluster)
	ld d, (ix + fat_fileTableStartCluster + 1)

	ld bc, (regA)
	;check if index is 0
	or a
	ld hl, 0x0000
	sbc hl, bc
	jr z, startClusterFound

	ex de, hl
	;hl = startCluster

	ld a, (iy + driveTableDevfd)
startClusterLoop:
	push ix
	call fat_nextCluster
	pop ix
	jp c, error ;the chain shouldn't end
	dec c
	jr nz, startClusterLoop
	djnz startClusterLoop
	ex de, hl
startClusterFound:
	;de = start cluster
	ld (fat_rw_cluster), de


	;calculate the address to start reading
	ld hl, regA
	call ld16
	call fat_clusterToAddr

	;calculate offset relative to the cluster
	ld e, (ix + fileTableOffset)
	ld d, (ix + fileTableOffset + 1)
	;de = offset[15..0]
	;relOffs = offs % (sectorsPerCluster * 512)
	ld a, (iy + fat_sectorsPerCluster)
	ld b, 0 ;bitmask
relOffsLoop:
	sla b
	inc b
	srl a
	jr nc, relOffsLoop

	and d
	;de = relOffs
	push de

	ld hl, regB
	call ld16
	;(regB) = relOffs

	ex de, hl
	ld hl, regA
	call add32
	;(regA) = startAddr

	ex de, hl ;de = regA

	ld a, (iy + driveTableDevfd)

	ld h, K_SEEK_SET
	push ix
	push af
	call k_lseek
	pop af
	pop ix

	pop bc ;relOffs
	ld hl, (fat_rw_clusterSize)
	or a
	sbc hl, bc
	push hl ;maximum count in first cluster

readCluster:
	ld hl, (fat_rw_remCount)
	ld de, (fat_rw_clusterSize)
	or a
	sbc hl, de
	pop hl ;count
	jr c, lastCluster

	;read(clustersize - clusteroffs)
	ld de, (fat_rw_dest)
	push de
	push ix
	push af
	call k_read
	pop af
	pop ix
	pop hl
	add hl, de ;buffer += count
	ld (fat_rw_dest), hl
	ld hl, (fat_rw_totalCount)
	add hl, de ;totalCount += count
	ld (fat_rw_totalCount), hl

	ld hl, (fat_rw_cluster)
	push ix
	call fat_nextCluster
	pop ix
	jr c, error ;unexpected end of chain
	ld (fat_rw_cluster), hl
	ex de, hl
	ld hl, regA
	call ld16
	call fat_clusterToAddr
	ex de, hl
	ld h, K_SEEK_SET
	push ix
	call k_lseek
	pop ix
	jr readCluster
	


lastCluster:
	;read(remCount)
	ld hl, (fat_rw_remCount)
	ld de, (fat_rw_dest)

	call k_read
	ld hl, (fat_rw_totalCount)
	add hl, de ;totalCount += count
	ex de, hl
	;de = total count

	ret

rootDir:
	;lseek offset + rootDirStart
	ld a, (iy + driveTableDevfd)
	ld b, iyh
	ld c, iyl
	ld hl, fat_rootDirStartAddr
	add hl, bc
	ld de, regA
	call ld32

	ld b, ixh
	ld c, ixl
	ld hl, fileTableOffset
	add hl, bc
	ex de, hl
	call add32
	ex de, hl

	;(de) = offset
	ld h, K_SEEK_SET
	push af
	call k_lseek
	pop af

	ld de, (fat_rw_dest)
	ld hl, (fat_rw_remCount)
	jp k_read

error:
	ld a, 1
	ret
.endf

.func fat_write:
;; Copy data from memory to a file
;;
;; Input:
;; : ix - file entry addr
;; : (de) - buffer
;; : bc - count
;;
;; Output:
;; : a - errno
;; : de - count

	;*******************************************;
	;                                           ;
	;  TODO test and debug multi-cluster write  ;
	;                                           ;
	;*******************************************;

	ld (fat_rw_remCount), bc
	ld (fat_rw_dest), de
	ld de, 0
	ld (fat_rw_totalCount), de

	;get the drive table entry of the filesystem for clustersize, devfd, etc.
	ld a, (ix + fileTableDriveNumber)
	call getDriveAddr
	jp c, error ;drive number out of bounds
	push hl
	pop iy
	;iy = table entry address

	;check if root dir (cluster = 0)
	xor a
	ld b, (ix + fat_fileTableStartCluster)
	cp b
	jr nz, notRootDir
	ld b, (ix + fat_fileTableStartCluster + 1)
	cp b
	jp z, rootDir

notRootDir:
	ld a, (iy + fat_sectorsPerCluster)
	ld h, a
	sla h
	ld l, 0
	ld (fat_rw_clusterSize), hl

	;calculate the starting cluster of the write
	;a = sectorsPerCluster
	ld hl, fileTableOffset
	ld d, ixh
	ld e, ixl
	add hl, de
	ld de, regA
	call ld32

	ex de, hl
	call rshiftbyte32
clusterIndexLoop:
	call rshift32
	srl a
	jr nc, clusterIndexLoop

	;(regA) = index of cluster in chain (16-bit)

	ld e, (ix + fat_fileTableStartCluster)
	ld d, (ix + fat_fileTableStartCluster + 1)

	ld bc, (regA)
	;check if index is 0
	or a
	ld hl, 0x0000
	sbc hl, bc
	jr z, startClusterFound

	ex de, hl
	;hl = startCluster

	ld a, (iy + driveTableDevfd)
startClusterLoop:
	push ix
	call fat_nextCluster
	pop ix
	jp c, error ;the chain shouldn't end
	dec c
	jr nz, startClusterLoop
	djnz startClusterLoop
	ex de, hl
startClusterFound:
	;de = start cluster
	ld (fat_rw_cluster), de


	;calculate the address to start writing
	ld hl, regA
	call ld16
	call fat_clusterToAddr

	;calculate offset relative to the cluster
	ld e, (ix + fileTableOffset)
	ld d, (ix + fileTableOffset + 1)
	;de = offset[15..0]
	;relOffs = offs % (sectorsPerCluster * 512)
	ld a, (iy + fat_sectorsPerCluster)
	ld b, 0 ;bitmask
relOffsLoop:
	sla b
	inc b
	srl a
	jr nc, relOffsLoop

	and d
	;de = relOffs
	push de

	ld hl, regB
	call ld16
	;(regB) = relOffs

	ex de, hl
	ld hl, regA
	call add32
	;(regA) = startAddr

	ex de, hl ;de = regA

	ld a, (iy + driveTableDevfd)

	ld h, K_SEEK_SET
	push ix
	push af
	call k_lseek
	pop af
	pop ix

	pop bc ;relOffs
	ld hl, (fat_rw_clusterSize)
	or a
	sbc hl, bc
	push hl ;maximum count in first cluster

writeCluster:
	ld hl, (fat_rw_remCount)
	ld de, (fat_rw_clusterSize)
	or a
	sbc hl, de
	pop hl ;count
	jr c, lastCluster

	;write(clustersize - clusteroffs)
	ld de, (fat_rw_dest)
	push de
	push ix
	push af
	call k_write
	pop af
	pop ix
	pop hl
	add hl, de ;buffer += count
	ld (fat_rw_dest), hl
	ld hl, (fat_rw_totalCount)
	add hl, de ;totalCount += count
	ld (fat_rw_totalCount), hl

	ld hl, (fat_rw_cluster)
	push ix
	call fat_nextCluster
	pop ix
	jp c, error ;unexpected end of chain
	ld (fat_rw_cluster), hl
	ex de, hl
	ld hl, regA
	call ld16
	call fat_clusterToAddr
	ex de, hl
	ld h, K_SEEK_SET
	push ix
	call k_lseek
	pop ix
	jr writeCluster
	


lastCluster:
	;write(remCount)
	ld hl, (fat_rw_remCount)
	ld de, (fat_rw_dest)

	push ix
	call k_write
	pop ix
	cp 0
	jp nz, error
	ld hl, (fat_rw_totalCount)
	add hl, de ;totalCount += count
	push hl ;totalCount
	ex de, hl
	ld hl, regA
	call ld16 ;regA = totalCount
	ex de, hl ;de=regA

	;offset += totalCount
	;if (offset > size) size = offset
	ld b, ixh
	ld c, ixl
	ld hl, fileTableOffset
	add hl, bc ;hl = offset
	call add32 ;offset = offset + totalCount
	ld d, h
	ld e, l ;hl = de = offset
	ld bc, fileTableSize-(fileTableOffset)
	add hl, bc ;hl = size
	;de = offset, hl = size
	push hl ;size
	push de ;offset
	call cp32
	pop hl ;offset
	pop de ;size
	jr c, end

	;offset >= size -> size = offset
	call ld32
	;TODO write new size to disk
	push de
	ld de, fat_fileTableDirEntryAddr-(fileTableOffset)
	add hl, de ;hl=dirEntry
	ex de, hl ;de=dirEntry
	ld hl, regA
	ld a, 0x1c
	call ld8 ;hl=regA=1c
	call add32 ;hl=regA=dirEntry->size
	ex de, hl
	ld h, K_SEEK_SET
	ld a, (iy + driveTableDevfd)
	call k_lseek
	pop de
	cp 0
	jr nz, error

	ld a, (iy + driveTableDevfd)
	ld hl, 4
	call k_write
	cp 0
	jr nz, error
	

end:
	pop de ;totalCount
	xor a

	ret

rootDir:
	;lseek offset + rootDirStart
	ld a, (iy + driveTableDevfd)
	ld b, iyh
	ld c, iyl
	ld hl, fat_rootDirStartAddr
	add hl, bc
	ld de, regA
	call ld32

	ld b, ixh
	ld c, ixl
	ld hl, fileTableOffset
	add hl, bc
	ex de, hl
	call add32
	ex de, hl

	;(de) = offset
	ld h, K_SEEK_SET
	push af
	call k_lseek
	pop af

	ld de, (fat_rw_dest)
	ld hl, (fat_rw_remCount)
	jp k_write

error:
	ld a, 1
	ret
.endf

.func fat_fctl:

	ret
.endf

.func fat_nextCluster:
;; Find the next cluster of a chain from the first FAT
;;
;; Input:
;; : a - device fd
;; : hl - current cluster
;;
;; Output:
;; : hl - next cluster
;; : carry - the current cluster is the last of the chain
;;
;; Preserved:
;; : a

	add hl, hl ;double the cluster number to get its offset in the FAT
	ex de, hl
	ld hl, regA
	call clear32
	call ld16
	push hl

	ld d, ixh
	ld e, ixl
	ld hl, fat_fat1StartAddr
	add hl, de
	ex de, hl
	;(de) = fat1StartAddr
	pop hl
	call add32 ;clusterOffs + fat1StartAddr
	ex de, hl

	push af
	ld h, K_SEEK_SET
	call k_lseek
	pop af

	ld de, regA
	ld hl, 2 ;count
	push af
	call k_read
	;TODO error checking

	;check if fat entry is end of chain
	ld hl, (regA)

	xor a
	cp h
	jr z, check00
	dec a
	cp h
	jr z, checkFF
validCluster:
	pop af
	or a
	ret

check00:
	ld a, 1
	cp l
	jr c, validCluster
eoc:
	pop af
	scf
	ret

checkFF:
	ld a, 0xf7
	cp l
	jr c, eoc
	jr validCluster
.endf

.func fat_clusterToAddr:
;; Calculate the starting address of a cluster
;;
;; Input:
;; : (hl) - 32-bit cluster number
;; : iy - drive table entry
;;
;; Output:
;; : (hl) - address

	;subtract 2 from the cluster, because of how FAT works
	call dec32
	call dec32

	ld a, (iy + fat_sectorsPerCluster)

	call lshiftbyte32
loop:
	call lshift32
	srl a
	jr nc, loop

	push hl
	ld hl, fat_dataStartAddr
	ld d, iyh
	ld e, iyl
	add hl, de
	ex de, hl
	pop hl
	call add32 ;relAddr += dataStartAddr

	ret
.endf

.func fat_buildFilename:
;; Creates a 8.3 string from a directory entry
;;
;; Input:
;; : (hl) - dir entry
;; : (de) - filename buffer (max. length: 13 bytes)
;;
;; Destroyed:
;; : a, bc, de, hl

	push de
	;copy the first 8 chars of the dir entry
	ld bc, 8
	ldir
	ld a, ' '
	ld (de), a

	pop de
terminateName:
	ld a, (de)
	cp ' '
	inc de
	jr nz, terminateName
	dec de

	;de now points to the char after the name, hl to the extension of the entry
	ld a, (hl)
	cp ' '
	jr z, end
	ld a, '.'
	ld (de), a
	inc de

	ld b, 3
extension:
	ld a, (hl)
	cp ' '
	jr z, end
	ld (de), a
	inc hl
	inc de
	djnz extension

end:
	ld a, 0
	ld (de), a
	ret
.endf
