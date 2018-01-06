SECTION rom_code

INCLUDE "iomap.h"

PUBLIC bankSwitch

bankSwitch:
;; Switch to a physical RAM bank.
;;
;; Bank index doesn't get checked for validity.
;; The OS - ROM bank is guaranteed to stay selected.
;;
;; Input:
;; : a - bank

	and a, 0x07
	or a, 0x08
	out (BANKSEL_PORT), a
	ret
