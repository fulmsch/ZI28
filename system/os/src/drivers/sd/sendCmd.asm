SECTION rom_code
INCLUDE "drivers/sd.h"

PUBLIC sd_sendCmd

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
