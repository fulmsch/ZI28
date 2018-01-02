SECTION rom_code
INCLUDE "os_memmap.h"

EXTERN k_chdir

PUBLIC b_chdir
b_chdir:
	ld a, (argc)
	cp 2
	jr nz, invalidCall

	ld hl, argv
	inc hl
	inc hl

	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
	;(hl) = path name

	jp k_chdir

invalidCall:
	ret
