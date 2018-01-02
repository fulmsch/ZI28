SECTION rom_code
INCLUDE "math.h"
INCLUDE "os_memmap.h"

PUBLIC block_write

EXTERN block_init, block_nextBlock, block_calcCopyPointers

block_write:
;; Translate random access into block based write.
;;
;; Input:
;; : ix - file entry addr
;; : (de) - buffer
;; : bc - count
;; : (hl) - block device driver callback structure
;;
;; : de - count
;; : a - errno

	ld (block_memPtr), de
	ld e, (hl)
	inc hl
	ld d, (hl)
	inc hl
	ld (block_readCallback), de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld (block_writeCallback), de
	ld (block_remCount), bc
	ld de, 0
	ld (block_totalCount), de


	call block_init
	call c, partialWrite


	;while curBlock < endBlock
    ;while cp32(hl=curBlock, de=endBlock) == c
fullWriteLoop:
	cp 0 ;errno of prev command
	ret nz

	ld hl, block_endBlock
	ld de, block_curBlock
	call cp32
	jr nc, lastBlock

	call fullWrite
	jr fullWriteLoop


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
	jr nz, partialWrite

	jr fullWrite

end:
	cp 0
	ret nz

	ld de, (block_totalCount)

	;a is already 0
	ret




fullWrite:
; write an entire block to disk
	ld de, fullWriteReturn
	push de ;return address
	ld de, (block_memPtr)
	ld bc, block_curBlock
	ld hl, (block_writeCallback)
	jp (hl)

fullWriteReturn:
	cp 0
	ret nz

	ld bc, 512
	call block_nextBlock

	xor a
	ret




partialWrite:
; write part of a block to disk, utilizing the block buffer

	;read the entire block into the buffer
	ld de, partialWriteReadReturn
	push de ;return address
	ld de, block_buffer
	ld bc, block_curBlock
	ld hl, (block_readCallback)
	jp (hl)

partialWriteReadReturn:
	cp 0
	ret nz

	;copy data to be written into buffer
	call block_calcCopyPointers
	push bc ;number of bytes to be copied

	ex de, hl

	ldir


	ld de, partialWriteReturn
	push de ;return address
	ld de, block_buffer
	ld bc, block_curBlock
	ld hl, (block_writeCallback)
	jp (hl)

partialWriteReturn:
	pop bc ;number of changed bytes written
	cp 0
	ret nz

	call block_nextBlock

	ld hl, 0
	ld (block_relOffs), hl

	xor a
	ret




error:
	ld de, (block_totalCount)
	ret
