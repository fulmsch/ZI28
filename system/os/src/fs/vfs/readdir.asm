MODULE vfs_readdir

SECTION rom_code
INCLUDE "os.h"
INCLUDE "vfs.h"
INCLUDE "drive.h"

PUBLIC u_readdir, k_readdir

EXTERN fdToFileEntry

u_readdir:
	add a, fdTableEntries

k_readdir:
;; Get information about the next file in a directory.
;;
;; Input:
;; : a - dirfd
;; : (de) - stat
;;
;; Output:
;; : a - errno

	push af
	push de

	;check if fd exists
	call fdToFileEntry
	jr c, invalidFd
	ld a, (hl)
	cp 0x00
	jr z, invalidFd

	push hl
	pop ix

	;check if dirfd is a directory
	ld a, (ix + fileTableMode)
	and M_DIR
	jr z, error ;not a directory

	;check for valid file driver
	;get the drive table entry of the filesystem
	ld a, (ix + fileTableDriveNumber)
	ld h, 0 + (driveTable >> 8)
	ld l, a
	;hl = drive entry
	ld de, driveTableFsdriver
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	;de = fsdriver
	ld hl, 0
	or a
	sbc hl, de
	jr z, error ;driver null pointer
	ld hl, fs_readdir
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
	;(hl) = routine

	pop de ;stat
	pop af ;fd

	jp (hl)

invalidFd:
error:
	pop de
	pop de
	ld a, 1
	ret

