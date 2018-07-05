MODULE fatfs_read

SECTION rom_code
INCLUDE "os.h"
INCLUDE "vfs.h"
INCLUDE "fatfs.h"
INCLUDE "math.h"
INCLUDE "errno.h"

EXTERN k_read, k_lseek, fat_clusterToAddr, fat_nextCluster

PUBLIC fat_read
fat_read:
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
	ld h, 0 + (driveTable >> 8)
	ld l, a
	;hl = drive entry
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

DEFC ZERO_FLAG_BIT     = 0
DEFC OVERFLOW_FLAG_BIT = 1

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

	inc b

	ex de, hl
	;hl = startCluster

startClusterLoop:
	push ix
	call fat_nextCluster
	pop ix
	ld a, EBADFD
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

	ld h, SEEK_SET
	push ix
	push af
	call k_lseek
	pop af
	pop ix

	pop bc ;relOffs
	ld hl, (fat_rw_clusterSize)
	or a
	sbc hl, bc
	ex de, hl ;de = maximum count in first cluster

readCluster:
	ld hl, (fat_rw_remCount)
	ld bc, (fat_rw_clusterSize)
	scf
	sbc hl, bc
	jr c, lastCluster

	inc hl
	ld (fat_rw_remCount), hl
	ex de, hl ;hl = count

	;read(clustersize - clusteroffs)
	ld de, (fat_rw_dest)
	ld a, (iy + driveTableDevfd)
	push de
	push ix
	call k_read
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
	ld a, EBADFD
	jr c, error ;unexpected end of chain
	ld (fat_rw_cluster), hl
	ex de, hl
	ld hl, regA
	call ld16
	call fat_clusterToAddr
	ex de, hl
	ld h, SEEK_SET
	ld a, (iy + driveTableDevfd)
	push ix
	call k_lseek
	pop ix
	jr readCluster
	


lastCluster:
	;read(remCount)
	ld hl, (fat_rw_remCount)
	ld de, (fat_rw_dest)
	ld a, (iy + driveTableDevfd)

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
	ld h, SEEK_SET
	push af
	call k_lseek
	pop af

	ld de, (fat_rw_dest)
	ld hl, (fat_rw_remCount)
	jp k_read

error:
	;TODO replace calls to this with direct ret
	ret
