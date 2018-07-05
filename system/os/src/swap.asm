MODULE swap

SECTION rom_code
INCLUDE "os.h"
INCLUDE "vfs.h"
INCLUDE "errno.h"

EXTERN k_open

PUBLIC u_swapon, k_swapon
PUBLIC swap_fd

u_swapon:
k_swapon:
;; Select the file or partition to be used for storing process memory.
;;
;; Input:
;; : (hl) - path
;;
;; Output:
;; : a - errno
;;
;; Errors:
;; : EPERM - Swap already set up

;check if swap is already set up
	ld a, (swap_fd)
	cp 0xff
	ld a, EPERM
	ret nz

;open the file
	ld a, O_RDWR | O_CREAT
	ld d, h
	ld e, l
	call k_open
	cp 0
	ret nz

;store the fd
	ld a, e
	ld (swap_fd), a
	xor a
	ret

SECTION ram_os
swap_fd:
	DEFB 0
