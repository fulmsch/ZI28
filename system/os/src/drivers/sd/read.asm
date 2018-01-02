SECTION rom_code
INCLUDE "math.h"
INCLUDE "devfs.h"
INCLUDE "drivers/sd.h"
INCLUDE "os_memmap.h"

PUBLIC sd_read

EXTERN block_read

sd_read:
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
	ld hl, sd_blockCallback
	jp block_read


sd_readBlock:
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


	ld c, 0x80 ;TODO proper addressing

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
