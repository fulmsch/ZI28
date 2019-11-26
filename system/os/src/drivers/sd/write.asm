#code ROM

sd_write:
;; Write to a SD-card
;;
;; Input:
;; : ix - file entry addr
;; : (de) - buffer
;; : bc - count
;;
;; Output:
;; : de - count
;; : a - errno

; Errors: 0=no error
	ld hl, sd_blockCallback
	jp block_write


sd_writeBlock:
;; Write a block to a SD-card
;;
;; Input:
;; : ix - file entry addr
;; : (de) - buffer
;; : (bc) - 32-bit block number
;;
;; Output:
;; : de = count
;; : a - errno

#local
	push de ;buffer

	;calculate start address from sector number
	ld h, b
	ld l, c
	ld de, regA
	call ld32
	;(regA) = sector number relative to partition start
	ld d, ixh
	ld e, ixl
	ld hl, sd_fileTableStartSector
	add hl, de ;(hl) = sector offset
	ld de, regA
	ex de, hl
	call add32 ;(regA) = absolute sector number
	ld hl, regA
	call lshift9_32
	;(regA) = start address


	ld c, 0x80 ;TODO proper addressing

	call sd_enable

	ld a, SD_WRITE_BLOCK
	call sd_sendCmd
	jr c, error
	ld b, 10
	ld e, 0
	call sd_getResponse
	jr c, error

	ld a, 0xff
	out (c), a
	call sd_transferByte ;at least 8 clock cycles before write

	;send data packet
	ld a, 0xfe ;data token for WRITE_BLOCK
	out (c), a
	call sd_transferByte

	;send data block

	pop hl
	push hl ;to be cleared by error TODO

	ld d, 0
writeBlock1:
	;write the first 256 bytes
	outi
	call sd_transferByte
	dec d
	jr nz, writeBlock1
writeBlock2:
	;write the second 256 bytes
	outi
	call sd_transferByte
	dec d
	jr nz, writeBlock2

	;send CRC, which is ignored by the card
	ld a, 0xff
	out (c), a
	call sd_transferByte

	out (c), a
	call sd_transferByte

	;get data response
	call sd_transferByte
	in a, (c)
	and 0x1f
	cp 0x05 ;data accepted
	jr nz, error

	call sd_disable
	pop hl
	xor a
	ret

error:
	pop af ;clear stack
	call sd_disable
	ld a, 1
	ret
#endlocal
