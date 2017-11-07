.list

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

	;check if cluster = 0
	xor a
	ld b, (ix + fat_fileTableStartCluster)
	cp b
	jr nz, notZeroCluster
	ld b, (ix + fat_fileTableStartCluster + 1)
	cp b
	jp nz, notZeroCluster

	;check if root dir (filetype = dir)
	ld a, (ix + fileTableMode)
	bit M_DIR_BIT, a
	jp nz, rootDir

	;allocate the first cluster
	ld hl, 0x0000
	call fat_addCluster
	jp c, error

	;update directory entry
	ld (fat_rw_cluster), hl ;new cluster

	ld hl, regB
	ld a, 0x1a
	call ld8

	ld d, ixh
	ld e, ixl
	ld hl, fat_fileTableDirEntryAddr
	add hl, de
	ex de, hl
	ld hl, regB
	call add32
	ex de, hl
	;(de) = dirEntryAddr

	ld a, (iy + driveTableDevfd)
	ld h, SEEK_SET
	push af
	call k_lseek
	pop af

	ld de, fat_rw_cluster
	ld hl, 2
	push ix
	call k_write
	pop ix
	;TODO error handling

	ld hl, fat_rw_cluster
	ld a, (hl)
	ld (ix + fat_fileTableStartCluster), a
	inc hl
	ld a, (hl)
	ld (ix + fat_fileTableStartCluster + 1), a


notZeroCluster:
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
	ld a, (iy + driveTableDevfd)
	push de
	push ix
	call k_write
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
	ld a, (iy + driveTableDevfd)
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

	;only increase size for regular files
	ld a, (ix + fileTableMode)
	bit M_REG_BIT, a
	jr z, end
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
