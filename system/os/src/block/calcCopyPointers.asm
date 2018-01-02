SECTION rom_code
INCLUDE "os_memmap.h"

PUBLIC block_calcCopyPointers

;TODO give this a better name
block_calcCopyPointers:
;; Calculate the amount of bytes to be copied in a partial block operation
;;
;; Output:
;; bc - count
;; de - memory pointer
;; hl - buffer pointer

	ld hl, 512
	ld de, (block_relOffs)
	or a
	sbc hl, de
	push hl ;bytes to end of block
	;check if block_remCount < hl
	ld bc, (block_remCount)
	sbc hl, bc
	pop hl
	jr nc, remCount ;only read remCount bytes
	ld b, h
	ld c, l

remCount:
	ld hl, block_buffer
	add hl, de ;buffer + reloffs

	ld de, (block_memPtr)

	ret
