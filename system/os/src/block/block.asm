#data RAM
block_buffer:        defs 512
block_curBlock:      defs   4
block_endBlock:      defs   4
block_remCount:      defs   2
block_totalCount:    defs   2
block_relOffs:       defs   2
block_readCallback:  defs   2
block_writeCallback: defs   2
block_memPtr:        defs   2

#code ROM
;TODO give this a better name
block_calcCopyPointers:
;; Calculate the amount of bytes to be copied in a partial block operation
;;
;; Output:
;; bc - count
;; de - memory pointer
;; hl - buffer pointer

#local
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
#endlocal


block_nextBlock:
;; Advance to next block
;;
;; Input:
;; : bc - count

	ld hl, (block_totalCount)
	add hl, bc
	ld (block_totalCount), hl

	ld hl, (block_memPtr)
	add hl, bc
	ld (block_memPtr), hl

	ld hl, (block_remCount)
	or a
	sbc hl, bc
	ld (block_remCount), hl

	ld hl, block_curBlock
	jp inc32


#include "init.asm"
#include "read.asm"
#include "write.asm"
