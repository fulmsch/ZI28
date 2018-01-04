MODULE chdir

SECTION rom_code
INCLUDE "os.h"
INCLUDE "string.h"
INCLUDE "cli.h"

PUBLIC u_chdir, k_chdir

EXTERN k_open, k_close, realpath

u_chdir:
k_chdir:
;; Change the current working directory
;;
;; Input:
;; : (hl) - path
;;
;; Output:
;; : a - errno

	push hl

	ex de, hl
	ld a, O_RDONLY | O_DIRECTORY
	call k_open
	cp 0
	jr nz, error

	ld a, e
	call k_close

	pop hl
	call realpath
	ld de, env_workingPath
	call strcpy
	;de points to dest null terminator
	dec de
	ld a, (de)
	cp '/'
	jr z, removeSlash
	xor a
	ret

removeSlash:
	xor a
	ld hl, env_workingPath
	sbc hl, de
	ret z
	ld (de), a
	ret

error:
	pop hl
	ld a, 1
	ret
