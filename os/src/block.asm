;; Block device abstraction layer
;;
;; Translates random access into block based reads and writes.

.list

.func block_read:
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

	;get address of file offset
	ld de, fileTableOffset
	push ix
	pop hl
	add hl, de
	push hl
	;(hl) = file offset

	;calculate current block
	ld de, block_curBlock
	call ld32

	ld hl, block_curBlock
	call rshift9_32


	;calculate final block
	pop hl ;file offset
	push hl ;file offset
	ld de, block_endBlock
	call ld32

	ld de, (block_remCount)
	dec de
	ld hl, reg32
	call ld16

	ld hl, block_endBlock
	ld de, reg32
	call add32

	call rshift9_32


	;calculate offset relative to block start
	pop de ;file offset
	ld a, (de)
	ld l, a
	inc de
	ld a, (de)
	and 1
	ld h, a
	ld (block_relOffs), hl


	;TODO store sector currently in buffer, check if same

readLoop:
	ld de, return
	push de ;return address
	ld de, block_buffer
	ld bc, block_curBlock
	ld hl, (block_readCallback)
	jp (hl)

return:
	cp 0
	jr nz, error
	;TODO error checking

	ld hl, block_curBlock
	ld de, block_endBlock
	call cp32
	jr z, end

	ld hl, 512
	ld de, (block_relOffs)
	or a
	sbc hl, de
	ld b, h
	ld c, l
	push bc ;number of bytes to be copied

	ld hl, block_buffer
	add hl, de ;buffer + reloffs

	ld de, (block_memPtr)

	ldir

	pop bc
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
	call inc32

	ld hl, 0
	ld (block_relOffs), hl

	jr readLoop

end:
;last block
	ld hl, block_buffer
	ld de, (block_relOffs)
	add hl, de

	ld de, (block_memPtr)
	ld bc, (block_remCount)
	push bc
	ldir

	pop de
	ld hl, (block_totalCount)
	add hl, de
	ex de, hl

	xor a
	ret

error:
	ld de, (block_totalCount)
	ret
.endf ;block_read


.func block_write:
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

	;get address of file offset
	ld de, fileTableOffset
	push ix
	pop hl
	add hl, de
	push hl
	;(hl) = file offset

	;calculate current block
	ld de, block_curBlock
	call ld32

	ld hl, block_curBlock
	call rshift9_32


	;calculate final block
	pop hl ;file offset
	push hl ;file offset
	ld de, block_endBlock
	call ld32

	ld de, (block_remCount)
	dec de
	ld hl, reg32
	call ld16

	ld hl, block_endBlock
	ld de, reg32
	call add32

	call rshift9_32


	;calculate offset relative to block start
	pop de ;file offset
	ld a, (de)
	ld l, a
	inc de
	ld a, (de)
	and 1
	ld h, a
	ld (block_relOffs), hl

	ld de, fullWriteLoop ;return address
	push de
	xor a
	cp h
	jr nz, partialWrite
	cp l
	jr nz, partialWrite

	pop de
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

	ld hl, (block_totalCount)
	add hl, de
	ex de, hl

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

	;TODO create subroutine for this?
	ld bc, 512

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
	call inc32

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
	ld hl, 512
	ld de, (block_relOffs)
	or a
	sbc hl, de
	ld b, h
	ld c, l
	push bc ;number of bytes to be copied

	ld hl, block_buffer
	add hl, de ;buffer + reloffs

	ld de, (block_memPtr)
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

	ld hl, 0
	ld (block_relOffs), hl

	ld hl, block_curBlock
	call inc32

	xor a
	ret




error:
	ld de, (block_totalCount)
	ret
.endf ;block_write
