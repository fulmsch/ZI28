;; FAT-16 file system
.list
;TODO move all variables to ram

fat_fsDriver:
	.dw fat_init
	.dw fat_open

.define fat_fat1StartAddr     driveTableFsdata          ;4 bytes
.define fat_fat2StartAddr     fat_fat1StartAddr + 4     ;4 bytes
.define fat_rootDirStartAddr  fat_fat2StartAddr + 4     ;4 bytes
.define fat_dataStartAddr     fat_rootDirStartAddr + 4  ;4 bytes
.define fat_sectorsPerCluster fat_dataStartAddr + 4     ;1 byte


fat_fileDriver:
	.dw fat_read
	.dw 0x0000 ;fat_write
;	.dw fat_fctl

.define fat_fileTableStartCluster fileTableData                 ;2 bytes
.define fat_dirEntryAddr          fat_fileTableStartCluster + 2 ;4 bytes


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
	ld h, SEEK_SET
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
	ld bc, 4 ;fat_fat2StartAddr - fat_fat1StartAddr
	add hl, bc
	call clear32
	push de ;fat_fat1StartAddr
	push hl ;fat_fat2StartAddr

	push af
	push ix
	ld de, FAT_VBR_SECTORS_PER_FAT
	ld h, SEEK_SET
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
	ld bc, 4 ;fat_rootDirStartAddr - fat_fat2StartAddr
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
	ld de, 4 ;fat_dataStartAddr - fat_rootDirStartAddr
	add hl, de
	;hl = fat_dataStartAddr
	call clear32
	push hl ;fat_dataStartAddr

	push af
	push ix
	ld de, FAT_VBR_MAX_ROOT_DIR_ENTRIES
	ld h, SEEK_SET
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

	ld de, 4 ;fat_sectorsPerCluster - fat_dataStartAddr
	add hl, de
	;hl = fat_sectorsPerCluster
	push hl

	push af
	push ix
	ld de, FAT_VBR_SECTORS_PER_CLUSTER
	ld h, SEEK_SET
	call k_seek
	pop ix
	pop af

	pop de ;fat_sectorsPerCluster
	push af
	push ix
	ld hl, 1
	call k_read
	pop ix
	pop af

	ret
.endf ;fat_init

.func fat_open:
;; Creates a new file table entry
;;
;; Input:
;; : ix - table entry
;; : (de) - absolute path
;; : a - mode (not yet implemented)
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
	;populate: driver, size, startcluster
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

	ld bc, -4 ;fat_dataStartAddr - fat_rootDirStartAddr
	add hl, bc
	;(de) = size, (hl) = rootDirStart
	call sub32 ;size = dataStart - rootDirStart = rootDirSize

	ld hl, 5 ;fat_fileTableStartCluster - fileTableSize
	add hl, de
	;(hl) = startCluster
	;set startCluster to 0 to indicate the rootDir
	xor a
	ld (ix + fat_fileTableStartCluster), a
	ld (ix + fat_fileTableStartCluster + 1), a

	ld hl, (fat_open_path)
	;a = 0
	cp (hl)
	ret z ;root directory was requested

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
	jr error ;filename too long

copyFilenameCont:
	xor a
	ld (de), a
	;(hl) = '/' or 0x00
	ld (fat_open_path), hl

compareLoop:
	ld de, fat_open_dirEntryBuffer
	ld bc, 32 ;count
	push ix
	call fat_read
	pop ix

	;add count to offset
	ld hl, regA
	call ld16 ;load count into reg32
	ld d, h
	ld e, l

	ld b, ixh
	ld c, ixl
	ld hl, fileTableOffset
	add hl, bc
	call add32

	;TODO check for EOF
	ld hl, fat_open_dirEntryBuffer
	ld a, (hl)
	cp 0x00 ;end of dir reached, no match
	jr z, error
	cp 0x2e ;dot entry (. or ..), gets ignored
	jr z, compareLoop
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
	;populate: offset, size, startcluster, TODO dirEntryAddr
	ld b, ixh
	ld c, ixl
	ld hl, fileTableOffset
	add hl, bc
	call clear32

	ld bc, 4 ;fileTableSize - fileTableOffset
	add hl, bc

	ex de, hl
	;(de) = fileTableSize
	ld hl, fat_open_dirEntryBuffer + 0x1c
	call ld32

	ld a, (fat_open_dirEntryBuffer + 0x1a)
	ld (ix + fat_fileTableStartCluster), a
	ld a, (fat_open_dirEntryBuffer + 0x1a + 1)
	ld (ix + fat_fileTableStartCluster + 1), a


	ld hl, (fat_open_path)
	xor a
	cp (hl)
	ret z

	inc hl
	ld (fat_open_path), hl
	jp openFile

error:
	ld a, 1
	ret
.endf ;fat_open

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

	ld (fat_read_remCount), bc
	ld (fat_read_dest), de
	ld de, 0
	ld (fat_read_totalCount), de

	;get the drive table entry of the filesystem for clustersize, devfd, etc.
	ld a, (ix + fileTableDriveNumber)
	call getDriveAddr
	jp c, error ;drive number out of bounds
	push hl
	pop iy
	;iy = table entry address

	;check if root dir (cluster = 0)
	ld hl, fat_fileTableStartCluster
	ld d, ixh
	ld e, ixl
	add hl, de
	ex de, hl
	ld hl, regA
	call clear32
	call cp32
	jp z, rootDir


	ld a, (iy + fat_sectorsPerCluster)
	ld h, a
	sla h
	ld l, 0
	ld (fat_read_clusterSize), hl

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
	ld (fat_read_cluster), de


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

	ld h, SEEK_SET
	push ix
	push af
	call k_lseek
	pop af
	pop ix

	pop bc ;relOffs
	ld hl, (fat_read_clusterSize)
	or a
	sbc hl, bc
	push hl ;maximum count in first cluster

readCluster:
	ld hl, (fat_read_remCount)
	ld de, (fat_read_clusterSize)
	or a
	sbc hl, de
	pop hl ;count
	jr c, lastCluster

	;read(clustersize - clusteroffs)
	ld de, (fat_read_dest)
	push de
	push ix
	push af
	call k_read
	pop af
	pop ix
	pop hl
	add hl, de ;buffer += count
	ld (fat_read_dest), hl
	ld hl, (fat_read_totalCount)
	add hl, de ;totalCount += count
	ld (fat_read_totalCount), hl

	ld hl, (fat_read_cluster)
	push ix
	call fat_nextCluster
	pop ix
	jr c, error ;unexpected end of chain
	ld (fat_read_cluster), hl
	ex de, hl
	ld hl, regA
	call ld16
	call fat_clusterToAddr
	ex de, hl
	ld h, SEEK_SET
	push ix
	call k_lseek
	pop ix
	jr readCluster
	


lastCluster:
	;read(remCount)
	ld hl, (fat_read_remCount)
	ld de, (fat_read_dest)

	call k_read
	ld hl, (fat_read_totalCount)
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
	ld h, SEEK_SET
	push af
	call k_lseek
	pop af

	ld de, (fat_read_dest)
	ld hl, (fat_read_remCount)
	jp k_read

error:
	ret
.endf ;fat_read

.func fat_write:

.endf ;fat_write

.func fat_fctl:

.endf ;fat_fctl

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
	ld h, SEEK_SET
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
