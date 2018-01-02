SECTION rom_code
INCLUDE "math.h"
INCLUDE "os_memmap.h"

PUBLIC block_nextBlock

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
