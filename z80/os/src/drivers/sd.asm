;; SD-Card driver
.list

sd_fileDriver:
	.dw sd_read
	.dw sd_write


.define sd_fileTableStartSector dev_fileTableData

;.define SD_ENABLE out (82h), a
;.define SD_DISABLE out (83h), a

;SD command set
.define SD_GO_IDLE_STATE      0 + 40h ;Software reset
.define SD_SEND_OP_COND       1 + 40h ;Initiate initialization process
.define SD_SET_BLOCKLEN      16 + 40h ;Change R/W block size
.define SD_READ_SINGLE_BLOCK 17 + 40h ;Read a block
.define SD_WRITE_BLOCK       24 + 40h ;Write a block
.define SD_READ_OCR          58 + 40h ;Read OCR



.func sd_read:
;; Read from a SD-Card
;;
;; Input:
;; : ix - file entry addr
;; : (de) - buffer
;; : bc - count
;;
;; Output:
;; : de = count
;; : a - errno

; Errors: 0=no error
	ld hl, sd_readBlock
	jp block_read
.endf ;sd_read

.func sd_readBlock:
;; Read a block from a SD-Card
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
	ld de, reg32
	call ld32
	;(reg32) = sector number relative to partition start
	ld d, ixh
	ld e, ixl
	ld hl, sd_fileTableStartSector
	add hl, de ;(hl) = sector offset
	ld hl, reg32
	ex de, hl
	call add32 ;(reg32) = absolute sector number
	ld hl, reg32
	call lshift32
	ld hl, reg32
	call lshiftbyte32
	;(reg32) = start address

	SD_ENABLE

	ld hl, reg32
	ld a, SD_READ_SINGLE_BLOCK
	ld c, 80h ;TODO proper addressing
	call sd_sendCmd
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
	inc c
	out (c), a
	dec c
	nop
	nop
	ini
	jr nz, readBlock1
readBlock2:
	;and the second 256 bytes
	inc c
	out (c), a
	dec c
	nop
	nop
	ini
	jr nz, readBlock2

;Receive the crc and discard it
	ld b, 2
getCrc:
	inc c
	out (c), a
	dec c
	nop
	nop
	in a, (c)
	djnz getCrc

	SD_DISABLE
	xor a
	ret

error:
	pop af ;clear stack
	SD_DISABLE
	ld a, 1
	ret
.endf


.func sd_write:
;; Input:
;; : ix - file entry addr
;; : (de) - buffer
;; : bc - count
;;
;; Output:
;; : de - count
;; : a - errno

; Errors: 0=no error

	ret

.endf ;sd_write


.func sd_sendCmd:
;; Send a command to the SD-Card
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

; a: Command
; edcb: Argument

	;point to msb
	inc hl
	inc hl
	inc hl

	;command starts with b01
	or 40h

	;command index
	out (c), a
	inc c
	out (c), a
	dec c

	;argument
	ld b, 4
	outi

argLoop:
	inc c
	out (c), a
	dec c
	dec hl
	outi
	jr nz, argLoop

	inc c
	out (c), a
	dec c

	;optional crc
;	ld a, 0ffh
	out (c), a
	inc c
	out (c), a
	dec c

;Wait for cmd response
	ld b, 10
	ld e, 0
	jp sd_getResponse
.endf


.func sd_getResponse:
;; Look for a specific response from the SD-Card
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

	inc c
	out (c), a
	dec c
	nop
	nop
	in a, (c)
	cp e
	jr z, success
	djnz sd_getResponse

timeout:
	scf

success:
	ret
.endf

;.func delay100:
;	;Wait for approx. 100ms
;	ld b, 0
;	ld c, 41
;loop:
;	ex (sp), hl
;	ex (sp), hl
;	ex (sp), hl
;	ex (sp), hl
;	djnz delay100Loop
;	dec c
;	jr nz, delay100Loop
;	ret
;.endf ;delay100
