SECTION rom_code
INCLUDE "os.h"
INCLUDE "math.h"
INCLUDE "drive.h"
INCLUDE "fatfs.h"

PUBLIC fat_getClusterValue

EXTERN k_lseek, k_read

fat_getClusterValue:
;; Read the value of a cluster entry from the first FAT.
;;
;; Input:
;; : (iy) - drive entry
;; : hl - cluster number
;;
;; Output:
;; : hl - value
;; : carry - error

	add hl, hl ;double the cluster number to get its offset in the FAT
	ex de, hl
	ld hl, regA
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
	ld h, SEEK_SET
	call k_lseek
	pop af

	ld de, fat_clusterValue
	ld hl, 2 ;count
	push ix
	call k_read
	pop ix
	ld hl, (fat_clusterValue)
	cp 0
	ret z
	scf
	ret
