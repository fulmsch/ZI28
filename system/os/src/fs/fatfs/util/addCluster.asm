SECTION rom_code
PUBLIC fat_addCluster

EXTERN fat_findFreeCluster, fat_setClusterValue

fat_addCluster:
;; Add a cluster to both FATs.
;;
;; Input:
;; : hl - cluster or 0 for empty files
;; : (iy) - drive entry
;;
;; Output:
;; : hl - added cluster
;; : carry - error

; int addCluster(int base) {
; 	new = findFreeCluster();
; 	setCluster(new, 0xffff);
; 	if (base != 0) {
; 		//possibly seek to end of cluster chain
; 		setCluster(base, new);
; 	}
; 	base points to new, which contains 0xffff
; 	return new;
; }

	push hl ;base
	call fat_findFreeCluster
	jr c, error
	ex de, hl
	;hl = first free cluster
	push hl ;new
	ld de, 0xffff
	call fat_setClusterValue
	pop hl ;new
	pop de ;base
	ret c

	xor a
	cp d
	jr nz, appendCluster
	cp e
	ret z ;carry is reset

appendCluster:
	ex de, hl
	jp fat_setClusterValue

error:
	pop hl
	scf
	ret
