MODULE block_read

SECTION rom_code
INCLUDE "math.h"
INCLUDE "block.h"

PUBLIC block_read

EXTERN block_init, block_calcCopyPointers, block_nextBlock

block_read:
;; Translate random access into block based read.
;;
;; Input:
;; : ix - file entry addr
;; : (de) - buffer
;; : bc - count
;; : (hl) - block device driver callback structure
;;
;; Output:
;; : de - count
;; : a - errno

	ld (block_memPtr), de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld (block_readCallback), de
	ld (block_remCount), bc
	ld de, 0
	ld (block_totalCount), de


	call block_init
	call c, partialRead

fullReadLoop:
	cp 0 ;errno of prev command
	ret nz

	ld hl, block_endBlock
	ld de, block_curBlock
	call cp32
	jr nc, lastBlock

	call fullRead
	jr fullReadLoop


lastBlock:
	ld de, end
	push de ;return address

	ld hl, (block_remCount)
	xor a
	ld d, a
	ld e, a
	sbc hl, de
	ret z ;jp to end
	ld de, 512
	sbc hl, de
	jr nz, partialRead

	jr fullRead

end:
	cp 0
	ret nz

	ld de, (block_totalCount)


	;a is already 0
	ret




fullRead:
;read an entire block from disk
	ld de, fullReadReturn
	push de ;return address
	ld de, (block_memPtr)
	ld bc, block_curBlock
	ld hl, (block_readCallback)
	jp (hl)

fullReadReturn:
	cp 0
	ret nz

	ld bc, 512
	call block_nextBlock

	xor a
	ret




partialRead:
;read part of a block from disk, utilizing the block buffer

	;read the entire block into the buffer
	ld de, partialReadReturn
	push de ;return address
	ld de, block_buffer
	ld bc, block_curBlock
	ld hl, (block_readCallback)
	jp (hl)

partialReadReturn:
	cp 0
	ret nz

	;copy data to memory
	call block_calcCopyPointers
	push bc ;number of bytes to be copied
	ldir

	pop bc

	call block_nextBlock

	ld hl, 0
	ld (block_relOffs), hl

	xor a
	ret




error:
	ld de, (block_totalCount)
	ret
