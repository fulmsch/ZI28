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


.include "fs/fatfs/init.asm"
.include "fs/fatfs/open.asm"
.include "fs/fatfs/readdir.asm"
.include "fs/fatfs/fstat.asm"
.include "fs/fatfs/read.asm"
.include "fs/fatfs/write.asm"
