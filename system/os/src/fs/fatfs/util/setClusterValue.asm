SECTION rom_code
INCLUDE "os.h"
INCLUDE "math.h"
INCLUDE "fatfs.h"
INCLUDE "os_memmap.h"

PUBLIC fat_setClusterValue

EXTERN k_lseek, k_write

fat_setClusterValue:
;; Set the value of a cluster in both FATs.
;;
;; Input:
;; : hl - cluster
;; : de - new value
;; : (iy) - drive entry
;;
;; Output:
;; : carry - error

	ld (fat_clusterValue), de

	add hl, hl ;double the cluster number to get its offset in the FAT
	ex de, hl
	ld hl, fat_clusterValueOffset1
	call ld16 ;cluster offset
	ld de, fat_clusterValueOffset2
	call ld32 ;regB = cluster offset

	ld d, iyh
	ld e, iyl
	ld hl, fat_fat1StartAddr
	add hl, de
	ex de, hl
	;(de) = fat1StartAddr
	ld hl, fat_clusterValueOffset1
	call add32 ;clusterOffs + fat1StartAddr
	ld hl, fat_fat2StartAddr - (fat_fat1StartAddr)
	add hl, de
	ex de, hl
	;(de) = fat2StartAddr
	ld hl, fat_clusterValueOffset2
	call add32 ;clusterOffs + fat2StartAddr

	ld a, (iy + driveTableDevfd)
	;write to FAT 1
	ld de, fat_clusterValueOffset1
	push af
	ld h, SEEK_SET
	call k_lseek
	pop af

	ld de, fat_clusterValue
	ld hl, 2 ;count
	push af
	push ix
	call k_write
	pop ix
	cp 0
	jr nz, error
	pop af

	;write to FAT 2
	ld de, fat_clusterValueOffset2
	push af
	ld h, SEEK_SET
	call k_lseek
	pop af

	ld de, fat_clusterValue
	ld hl, 2 ;count
	push ix
	call k_write
	pop ix
	cp 0
	ret z
	scf
	ret

error:
	pop af
	scf
	ret
