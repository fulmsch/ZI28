SECTION rom_code

INCLUDE "os.h"
INCLUDE "drive.h"

EXTERN storeAndCallFsInit, k_open

PUBLIC mountRoot
mountRoot:
;; Populate the root node of the filesystem.
;;
;; Input:
;; : de - device name
;; : a - fs type

	push af
	ld a, O_RDWR
	call k_open
	pop hl ;h = fs type
	cp 0
	ret nz
	ld a, e ;fd
	ld d, h ;fs type
	ld ix, driveTable
	ld (ix + driveTableDevfd), a
	jp storeAndCallFsInit
