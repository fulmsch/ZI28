SECTION rom_code
INCLUDE "fatfs.h"

PUBLIC fat_findFreeCluster

EXTERN fat_getClusterValue

fat_findFreeCluster:
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
	ex de, hl
	push hl
	call fat_getClusterValue
	pop de
	ret c
	inc de
	xor a
	cp h
	jr nz, loop
	cp l
	jr nz, loop

	dec de
	;de is a free cluster
	ld (iy + fat_firstFreeCluster), e
	ld (iy + fat_firstFreeCluster + 1), d
	;carry is cleared from cp
	ret
