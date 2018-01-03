SECTION rom_code

INCLUDE "iomap.h"

PUBLIC bankSwitch, bankRestore, bankOs

bankSwitch:
;; Switch to a physical RAM bank and store the new index.
;;
;; Bank index doesn't get checked for validity.
;; The OS - ROM bank is guaranteed to stay selected.
;;
;; Input:
;; : a - bank

	and a, 0x07
	ld (storedBank), a
	or a, 0x08
	out (BANKSEL_PORT), a
	ret


bankRestore:
;; Switch to the stored RAM bank.
;;
;; Input:
;; : None

	push af
	ld a, (storedBank)
	or a, 0x08
	out (BANKSEL_PORT), a
	pop af
	ret


bankOs:
;; Switch to the os RAM bank.
;;
;; Input:
;; : None

	ld a, 0x05 | 0x08
	out (BANKSEL_PORT), a
	ret


SECTION bram_os
storedBank:
	defb 0
