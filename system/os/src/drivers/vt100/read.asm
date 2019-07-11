SECTION rom_code
INCLUDE "drivers/vt100.h"

PUBLIC vt100_read

vt100_read:
;; Read from the USB-connection on the mainboard
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

	xor a
	ld d, a
	ld e, a
	ret
