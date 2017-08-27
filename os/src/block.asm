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
;; : (hl) - block device driver callback
;;
;; Output:
;; : de - count
;; : a - errno

	ld (block_callback), hl
	ld (block_dest), de
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
	ld hl, (block_callback)
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

	ld de, (block_dest)

	ldir

	pop bc
	ld hl, (block_totalCount)
	add hl, bc
	ld (block_totalCount), hl

	ld hl, (block_dest)
	add hl, bc
	ld (block_dest), hl

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

	ld de, (block_dest)
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
;; : (hl) - block device driver callback

.endf ;block_write
