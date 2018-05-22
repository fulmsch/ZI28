SECTION rom_code
INCLUDE "errno.h"

PUBLIC u_breq

EXTERN bankMap

u_breq:
;; Request a new bank to the current process.
;;
;; If the call was successful, the new bank is selected.
;;
;; Input:
;; : None
;;
;; Output:
;; : a - errno
;; : e - bank index
;;
;; Errors:
;; : ENOMEM - No new bank available.

	;TODO check if current process can accept new bank
;scan bankMap for 0x00
	ld bc, 6
	ld hl, bankMap
	xor a
	cpir
	jr nz, errNoMem ;no free bank
	;hl - bankMap = free bank
	ld a, ;TODO current pid
	ld (hl), a
	ld de, bankMap
	sbc hl, de
	;l = free bank
	ld a, l
	;TODO store new bank in process data area

	ld e, a
	call bankSwitch
	xor a
	ret

errNoMem:
	ld a, ENOMEM
	ret
