MODULE sd_init

SECTION rom_code
INCLUDE "math.h"
INCLUDE "devfs.h"
INCLUDE "drivers/sd.h"

EXTERN sd_partitionDriver, devfs_addDev

PUBLIC sd_init

sd_init:
;; Initialises the SD-card
;;

	;TODO read mbr, find partitions

	ld c, 0x80 ;TODO proper addressing

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



	ld hl, sda1Name
	ld de, sd_partitionDriver
	ld a, 1
	call devfs_addDev
	call clear32

; partition offset, should be read from the MBR
	ld a, 0x80
	call ld8

	xor a
	ret

error:
	call sd_disable
	ld a, -1
	ret


sda1Name:
	DEFM "SDA1", 0x00
