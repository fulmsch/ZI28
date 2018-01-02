SECTION rom_code
PUBLIC fat_nextCluster

EXTERN fat_getClusterValue

fat_nextCluster:
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
