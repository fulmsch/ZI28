.list

.func fat_unlink:
;; Mark the directory entry as deleted and clear the cluster chain.
;;
;; Input:
;; : ix - table entry
;;
;; Output:
;; : a - errno

	;get the drive table entry of the filesystem
	ld a, (ix + fileTableDriveNumber)
	call getDriveAddr
	jp c, error ;drive number out of bounds
	push hl
	pop iy
	;iy = table entry address

	;check if a cluster is allocated
	ld l, (ix + fat_fileTableStartCluster)
	ld h, (ix + fat_fileTableStartCluster + 1)
	ld bc, 0
	or a ;clear carry
	sbc hl, bc
	jr z, emptyFile

	;hl = first cluster
	call fat_clearClusterChain
	jr c, error

emptyFile:
	;write 0xe5 to the first byte of the dir entry
	ld d, ixh
	ld e, ixl
	ld hl, fat_fileTableDirEntryAddr
	add hl, de
	ex de, hl ;(de) = dir entry address
	ld a, (iy + driveTableDevfd)
	push af
	ld h, SEEK_SET
	call k_lseek

	ld hl, 1
	ld de, fat_dirEntryBuffer
	ld a, 0xe5
	ld (de), a
	pop af
	jp k_write

error:
	ld a, 1
	ret
.endf
