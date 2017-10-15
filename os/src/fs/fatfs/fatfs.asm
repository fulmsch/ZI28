;; FAT-16 file system
.list

fat_fsDriver:
	.dw fat_init
	.dw fat_open
	.dw 0x000 ;fat_close
	.dw fat_readdir
	.dw fat_fstat


fat_fileDriver:
	.dw fat_read
	.dw fat_write


.func fat_findFreeCluster:
;; Find the first free cluster of the first FAT.
;;
;; Starts searching at fat_firstFreeCluster and stores the next free cluster
;; there. TODO: wrap around when the end of the FAT is reached.
;;
;; Input:
;; : (iy) - drive entry
;;
;; Output:
;; : de - free cluster
;; : carry - error

	ld e, (iy + fat_firstFreeCluster)
	ld d, (iy + fat_firstFreeCluster + 1)

loop:
	push de
	call fat_getClusterValue
	pop de
	ret c
	inc de
	xor a
	cp (hl)
	jr nz, loop
	inc hl
	cp (hl)
	jr nz, loop

	dec de
	;de is a free cluster
	ld (iy + fat_firstFreeCluster), e
	ld (iy + fat_firstFreeCluster + 1), d
	;carry is cleared from cp
	ret
.endf

.func fat_getClusterValue:
;; Read the value of a cluster entry from the first FAT.
;;
;; Input:
;; : (iy) - drive entry
;; : hl - cluster number
;;
;; Output:
;; : (hl) = regA - value
;; : carry - error

	add hl, hl ;double the cluster number to get its offset in the FAT
	ex de, hl
	ld hl, regA
	call clear32
	call ld16
	push hl

	ld d, iyh
	ld e, iyl
	ld hl, fat_fat1StartAddr
	add hl, de
	ex de, hl
	;(de) = fat1StartAddr
	pop hl
	call add32 ;clusterOffs + fat1StartAddr
	ex de, hl

	ld a, (iy + driveTableDevfd)
	push af
	ld h, K_SEEK_SET
	call k_lseek
	pop af

	ld de, regA
	ld hl, 2 ;count
	call k_read
	cp 0
	ret z
	scf
	ret
.endf

.func fat_setClusterValue:
;; Set the value of a cluster in both FATs.
;;
;; Input:
;; : hl - cluster
;; : de - new value
;; : (iy) - drive entry
;;
;; Output:
;; : carry - error

	push hl
	ld hl, regC
	call ld16
	pop hl

	add hl, hl ;double the cluster number to get its offset in the FAT
	ex de, hl
	ld hl, regA
	call clear32
	call ld16
	ld de, regB
	call ld32

	ld d, iyh
	ld e, iyl
	ld hl, fat_fat1StartAddr
	add hl, de
	ex de, hl
	;(de) = fat1StartAddr
	ld hl, regA
	call add32 ;clusterOffs + fat1StartAddr
	ld hl, fat_fat2StartAddr - (fat_fat1StartAddr)
	add hl, de
	ex de, hl
	;(de) = fat2StartAddr
	ld hl, regB
	call add32

	ld a, (iy + driveTableDevfd)
	;write to FAT 1
	ld de, regA
	push af
	ld h, K_SEEK_SET
	call k_lseek
	pop af

	ld de, regC
	ld hl, 2 ;count
	push af
	call k_write
	cp 0
	jr nz, error
	pop af

	;write to FAT 2
	ld de, regB
	push af
	ld h, K_SEEK_SET
	call k_lseek
	pop af

	ld de, regC
	ld hl, 2 ;count
	call k_write
	cp 0
	ret z
	scf
	ret

error:
	pop af
	scf
	ret
.endf

.func fat_addCluster:
;; Add a cluster to both FATs.
;;
;; Input:
;; : hl - cluster or 0 for empty files
;; : (iy) - drive entry
;;
;; Output:
;; : hl - added cluster
;; : carry - error

; int addCluster(int i) {
; 	f = findFreeCluster();
; 	setCluster(f, 0xffff);
; 	if (i != 0) {
; 		//possibly seek to end of cluster chain
; 		setCluster(i, f);
; 	}
; 	i points to f, which contains 0xffff
; 	return f;
; }

	push hl
	call fat_findFreeCluster
	jr c, error
	ex de, hl
	;hl = first free cluster
	push hl
	ld de, 0xffff
	call fat_setClusterValue
	pop hl ;f
	pop de ;i
	ret c

	xor a
	cp h
	jr nz, appendCluster
	cp l
	ret z ;carry is reset

appendCluster:
	ex de, hl
	jp fat_setClusterValue

error:
	pop hl
	scf
	ret
.endf

.func fat_nextCluster:
;; Find the next cluster of a chain from the first FAT
;;
;; Input:
;; : hl - current cluster
;; : (iy) - drive entry
;;
;; Output:
;; : hl - next cluster
;; : carry - the current cluster is the last of the chain

	call fat_getClusterValue
	ret c

	;check if fat entry is end of chain
	ld hl, (regA)

	xor a
	cp h
	jr z, check00
	dec a
	cp h
	jr z, checkFF
validCluster:
	or a
	ret

check00:
	ld a, 1
	cp l
	jr c, validCluster
eoc:
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


.include "fs/fatfs/init.asm"
.include "fs/fatfs/open.asm"
.include "fs/fatfs/readdir.asm"
.include "fs/fatfs/fstat.asm"
.include "fs/fatfs/read.asm"
.include "fs/fatfs/write.asm"
