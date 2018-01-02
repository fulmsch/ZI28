SECTION rom_code
PUBLIC fat_clearClusterChain

EXTERN fat_nextCluster, fat_setClusterValue

fat_clearClusterChain:
;; Clear a chain starting at the specified cluster.
;;
;; Input:
;; : hl - cluster
;; : (iy) - drive entry
;;
;; Output:
;; : carry - error

	push hl ;current cluster
loop:
	call fat_nextCluster
	ex (sp), hl ;stack: next cluster, hl: current cluster to be cleared
	push af

	ld de, 0x0000
	call fat_setClusterValue
	jr c, error
	pop af
	jr nc, loop ;not end of cluster chain

	pop hl
	or a ;clear carry
	ret

error:
	;carry is set
	pop hl
	pop hl
	ret
