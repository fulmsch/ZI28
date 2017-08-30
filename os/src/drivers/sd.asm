;; SD-card driver
;;
;; Based on this design: <http://www.ecstaticlyrics.com/electronics/SPI/fast_z80_interface.html>
;;
;; Port 0 is the transfer buffer.  
;; A write to port 1 transfers a byte between the buffer and the SD-card.  
;; Writing to port 2 enables the SD-card, writing to port 3 disabled it.

.list

sd_fileDriver:
	.dw sd_read
	.dw sd_write


.define sd_fileTableStartSector dev_fileTableData


;SD command set
.define SD_GO_IDLE_STATE      0 + 40h ;Software reset
.define SD_SEND_OP_COND       1 + 40h ;Initiate initialization process
.define SD_SET_BLOCKLEN      16 + 40h ;Change R/W block size
.define SD_READ_SINGLE_BLOCK 17 + 40h ;Read a block
.define SD_WRITE_BLOCK       24 + 40h ;Write a block
.define SD_READ_OCR          58 + 40h ;Read OCR


.func sd_init:
;; Initialises the SD-card
;;
;; Input:
;; : ix - devfs entry address

	;TODO read mbr, find partitions

	ld c, 80h ;TODO proper addressing

	ld hl, regA
	call clear32

	call sd_disable

	;Send 80 clock pulses
	ld b, 10
	inc c
poweronLoop:
	out (c), a
	djnz poweronLoop
	dec c

	call sd_enable

	ld a, SD_GO_IDLE_STATE
	ld hl, regA
	call sd_sendCmd

	ld b, 8
	ld e, 1
	call sd_getResponse
	jr c, error

poll00:
	;Doesn't work without these loops, but there are errors if this is in sd_sendCmd
	call sd_transferByte
	djnz poll00


	ld d, 11
operatingLoop:
	dec d
	jr z, error ;timeout

	ld a, SD_SEND_OP_COND
	ld hl, regA
	call sd_sendCmd
	ld b, 8
	ld e, 0
	call sd_getResponse
	jr nc, operatingSuccess

poll01:
	call sd_transferByte
	djnz poll01

	call delay100
	jr operatingLoop



operatingSuccess:
	call sd_transferByte
	djnz operatingSuccess

	;set blocksize to 512 bytes
	ld hl, regA
	ld de, 200h
	call ld16
	ld a, SD_SET_BLOCKLEN
	call sd_sendCmd
	ld b, 10
	ld e, 0
	call sd_getResponse
	jr c, error

poll02:
	call sd_transferByte
	djnz poll02

	call sd_disable

	xor a
	ret

error:
	call sd_disable
	ld a, -1
	ret
.endf

.func sd_read:
;; Read from a SD-card
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
	ld hl, sd_readBlock
	jp block_read

.endf

.func sd_readBlock:
;; Read a block from a SD-card
;;
;; Input:
;; : ix - file entry addr
;; : (de) - buffer
;; : (bc) - 32-bit block number
;;
;; Output:
;; : de = count
;; : a - errno

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


	ld c, 80h ;TODO proper addressing

	call sd_enable

	ld a, SD_READ_SINGLE_BLOCK
	call sd_sendCmd
	ld b, 10
	ld e, 0
	call sd_getResponse
	jr c, error

;Wait for data packet start
	ld b, 100
	ld e, 0feh
	call sd_getResponse
	jr c, error

	pop hl ;buffer

	ld b, 0
readBlock1:
	;read the first 256 bytes
	call sd_transferByte
	ini
	jr nz, readBlock1
readBlock2:
	;and the second 256 bytes
	call sd_transferByte
	ini
	jr nz, readBlock2

;Receive the crc and discard it
	ld b, 2
getCrc:
	call sd_transferByte
	in a, (c)
	djnz getCrc

	call sd_disable
	xor a
	ret

error:
	pop af ;clear stack
	call sd_disable
	ld a, 1
	ret
.endf


.func sd_write:
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
	ld hl,sd_writeBlock
	jp block_write

.endf

.func sd_writeBlock:
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


	ld c, 80h ;TODO proper addressing

	call sd_enable

	ld a, SD_WRITE_BLOCK
	call sd_sendCmd
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

	;wait until write is complete
	;TODO should instead be done before every command
	ld b, 100
	ld e, 0xff
	call sd_getResponse
	jr c, error

	call sd_disable
	pop hl
	xor a
	ret

error:
	pop af ;clear stack
	call sd_disable
	ld a, 1
	ret
.endf


.func sd_sendCmd:
;; Send a command to the SD-card
;;
;; Input:
;; : a - Command index
;; : c - Base port address
;; : (hl) - 32-bit argument
;;
;; Output:
;; : carry - timeout
;; : nc - no error
;;
;; Destroyed:
;; : a, b

	;point to msb
	inc hl
	inc hl
	inc hl

	;command index
	out (c), a
	call sd_transferByte

	;argument
	ld b, 4
	outd
argLoop:
	call sd_transferByte
	outd
	jr nz, argLoop
	call sd_transferByte

	;optional crc
	ld a, 95h ;needs to be 95h for CMD0, after that it's ignored
	out (c), a
	call sd_transferByte

	ret
.endf


.func sd_getResponse:
;; Look for a specific response from the SD-card
;;
;; Input:
;; : e - expected response
;; : b - number of retries
;; : c - base port address
;;
;; Output:
;; : carry - timeout
;; : nc - got correct response
;;
;; Destroyed:
;; : a, b

	call sd_transferByte
	in a, (c)
	cp e
	ret z
	djnz sd_getResponse

timeout:
	scf
.endf


.func sd_enable:
;; Set CS to low to enable the SD-card
;;
;; Input:
;; : c - base port address
;;
;; Destroyed:
;; : none

	inc c
	inc c
	out (c), a
	dec c
	dec c
	ret
.endf


.func sd_disable:
;; Set CS to low to enable the SD-card
;;
;; Input:
;; : c - base port address
;;
;; Destroyed:
;; : none

	inc c
	inc c
	inc c
	out (c), a
	dec c
	dec c
	dec c
	ret
.endf


.func sd_transferByte:
;; Transfer a byte between the buffer and the SD-card
;;
;; Destroyed:
;; : none

	inc c
	out (c), a
	dec c
	ret
.endf


.func delay100:
;; Wait for approx. 100ms
;;
;; Destroyed:
;; : none

	push bc

	ld b, 0
	ld c, 41
loop:
	ex (sp), hl
	ex (sp), hl
	ex (sp), hl
	ex (sp), hl
	djnz loop
	dec c
	jr nz, loop

	pop bc
	ret
.endf
