#code ROM

block_init:
;; Calculate the current and final block, and the relative offset
;;
;; Output:
;; : carry - start with a partial block
;; : no carry - start with a full block

#local
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
	ld hl, regA
	call ld16

	ld hl, block_endBlock
	ld de, regA
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


	xor a
	cp h
	jr nz, partial
	cp l
	ret z

partial:
	scf
	ret
#endlocal
