SECTION rom_code

INCLUDE "os.h"
INCLUDE "vfs.h"
INCLUDE "process.h"
INCLUDE "iomap.h"
INCLUDE "memmap.h"

PUBLIC u_exit

;EXTERN kernel_stackSave
EXTERN k_read, k_lseek
EXTERN swap_fd

;TODO use sysStack

u_exit:
;; Terminate the current process and return control to the parent.
;;
;; Input:
;; : a - exit status

;needs to return the following for fork:
; a = 1
; e - exit code of terminating process

;TODO what to do if trying to exit pid 1?
; - reboot the system
; - display reboot prompt
; - drop to kernel shell
; - halt the system / panic

	ld (exit_returnCode), a

	ld a, (process_pid)
	cp 1
	jp z, 0x0000

;TODO close all fds

	ld sp, sysStack

;restore process memory from swap
;TODO seek

	ld a, 0x00 | 0x08 ;make sure OS rom bank stays selected
	out (BANKSEL_PORT), a

	ld a, (swap_fd)
	ld de, process_dataSection
	ld hl, 0x8000
	call k_read


	or a, 0x01 | 0x08 ;make sure OS rom bank stays selected
	out (BANKSEL_PORT), a

	ld a, (swap_fd)
	ld de, 0xc000
	ld hl, 0x4000
	call k_read


	or a, 0x02 | 0x08 ;make sure OS rom bank stays selected
	out (BANKSEL_PORT), a

	ld a, (swap_fd)
	ld de, 0xc000
	ld hl, 0x4000
	call k_read


	ld a, (process_bank)
	or a, 0x08
	out (BANKSEL_PORT), a


;restore fds
	ld hl, u_fdTable
	ld de, process_fdTable
	ld bc, fdTableEntries
	ldir


;restore sp
	ld sp, (process_sp)

	ld a, (exit_returnCode)
	ld e, a
	ld a, 1
	ret



;	ld sp, (kernel_stackSave)
;	xor a
;	ret

SECTION ram_os
exit_returnCode:
	DEFB 0
