SECTION rom_code

INCLUDE "drive.h"

PUBLIC storeAndCallFsInit

storeAndCallFsInit:
;; Store and call the fs init routine
;;
;; Input:
;; : d - fs type
;; : ix - drive entry

	ld a, 0x07
	and d
	add a, a ;a = offset in fs driver table
	ld de, fsDriverTable
	add a, e
	ld e, a ;(de) = fsDriver
	ex de, hl ;(hl) = fsDriver

	ld e, (hl)
	inc hl
	ld d, (hl)
	;de = fsDriver

	and a ;clear carry
	ld hl, 0
	adc hl, de
	jr z, error ;fsdriver null pointer
	ld (ix + driveTableFsdriver), e
	ld (ix + driveTableFsdriver + 1), d

	ld hl, fs_init
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl

	jp (hl)


error:
	ld a, 1 ;invalid fs type
	ret
