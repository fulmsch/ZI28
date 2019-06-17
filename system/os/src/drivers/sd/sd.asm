SECTION rom_code
;; SD-card driver
;;
;; Based on this design: <http://www.ecstaticlyrics.com/electronics/SPI/fast_z80_interface.html>
;;
;; Port 0 is the transfer buffer.  
;; A write to port 1 transfers a byte between the buffer and the SD-card.  
;; Writing to port 2 enables the SD-card, writing to port 3 disabled it.

INCLUDE "drivers/sd.h"

PUBLIC sd_deviceDriver, sd_blockCallback
PUBLIC sd_enable, sd_disable, sd_transferByte, delay100

sd_deviceDriver:
	DEFW sd_init
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
