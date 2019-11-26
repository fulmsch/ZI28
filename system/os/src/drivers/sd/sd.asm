;; SD-card driver
;;
;; Based on this design: <http://www.ecstaticlyrics.com/electronics/SPI/fast_z80_interface.html>
;;
;; Port 0 is the transfer buffer.  
;; A write to port 1 transfers a byte between the buffer and the SD-card.  
;; Writing to port 2 enables the SD-card, writing to port 3 disabled it.

#define sd_fileTableStartSector dev_fileTableData

;SD command set
#define SD_GO_IDLE_STATE      0 + 0x40 ;Software reset
#define SD_SEND_OP_COND       1 + 0x40 ;Initiate initialization process
#define SD_SET_BLOCKLEN      16 + 0x40 ;Change R/W block size
#define SD_READ_SINGLE_BLOCK 17 + 0x40 ;Read a block
#define SD_WRITE_BLOCK       24 + 0x40 ;Write a block
#define SD_READ_OCR          58 + 0x40 ;Read OCR


#code ROM

sd_deviceDriver:
	DEFW sd_init
	DEFW sd_read
	DEFW sd_write

sd_partitionDriver:
	DEFW 0
	DEFW sd_read
	DEFW sd_write


sd_blockCallback:
	DEFW sd_readBlock
	DEFW sd_writeBlock


sd_enable:
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


sd_disable:
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


sd_transferByte:
;; Transfer a byte between the buffer and the SD-card
;;
;; Destroyed:
;; : none

	inc c
	out (c), a
	dec c
	ret


delay100:
;; Wait for approx. 100ms
;;
;; Destroyed:
;; : none

#local
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
#endlocal


sd_sendCmd:
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

#local
	ld d, a

busyLoop:
	;wait until the SD is not busy
	;TODO add timeout?
	ld b, 0
	ld e, 0xff
	call sd_getResponse
	jr c, busyLoop

	ld a, d

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
	ld a, 0x95 ;needs to be 0x95 for CMD0, after that it's ignored
	out (c), a
	call sd_transferByte

	ret
#endlocal


sd_getResponse:
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

#local
	call sd_transferByte
	in a, (c)
	cp e
	ret z
	djnz sd_getResponse

timeout:
	scf
#endlocal


#include "init.asm"
#include "read.asm"
#include "write.asm"
