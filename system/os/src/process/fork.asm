SECTION rom_code

INCLUDE "os.h"
INCLUDE "vfs.h"
INCLUDE "process.h"
INCLUDE "iomap.h"
INCLUDE "memmap.h"

EXTERN swap_fd, k_write

PUBLIC u_fork

;TODO use sysStack

u_fork:
;; Create a child process.
;;
;; Input:
;; : None
;;
;; Output:
;; : a - 0: is child / -1: error / 1: is parent
;; : e - errno / exit code of child
;;
;; Errors:
;; : ENOMEM - Insufficient memory available to save the current process.
;; : EPROCLIM - The limit on the number of processes has been reached.

;TODO error handling


;TODO duplicate all fds
;copy fd-table to process data area
	ld hl, u_fdTable
	ld de, process_fdTable
	ld bc, fdTableEntries
	ldir


;store stack pointer
	ld (process_sp), sp
	ld sp, sysStack


;store entire process memory in swap
	ld a, 0x00 | 0x08 ;make sure OS rom bank stays selected
	out (BANKSEL_PORT), a

	ld a, (swap_fd)
	ld de, process_dataSection
	ld hl, 0x8000
	call k_write


	or a, 0x01 | 0x08 ;make sure OS rom bank stays selected
	out (BANKSEL_PORT), a

	ld a, (swap_fd)
	ld de, 0xc000
	ld hl, 0x4000
	call k_write


	or a, 0x02 | 0x08 ;make sure OS rom bank stays selected
	out (BANKSEL_PORT), a

	ld a, (swap_fd)
	ld de, 0xc000
	ld hl, 0x4000
	call k_write


	ld a, (process_bank)
	or a, 0x08
	out (BANKSEL_PORT), a

	ld sp, (process_sp)

;increment pid
	ld hl, process_pid
	inc (hl)


;return
	xor a
	ld e, a

	ret
