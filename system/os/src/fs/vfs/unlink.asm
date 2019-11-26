u_unlink:

k_unlink:
;; Remove a file from the file system.
;;
;; Input:
;; : (de) - filename
;;
;; Output:
;; : a - errno

#local
	ld a, O_WRONLY
	call k_open
	cp 0
	ret nz
	ld a, e

	;get file entry address
	call fdToFileEntry
	jr c, error
	ld a, (hl)
	cp 00h
	jr z, error

	push hl
	pop ix

	ld a, (ix + fileTableMode)
	bit M_DIR_BIT, a
	jr nz, error ;directories must be removed with rmdir

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
	ld hl, fs_unlink
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
	;(hl) = routine

	push ix ;file entry
	ld de, return
	push de

	jp (hl)

return:
	pop hl ;file entry
	cp 0
	jr nz, error

	;clear file entry
	xor a
	ld b, fileTableEntrySize
clearEntry:
	ld (hl), a
	inc hl
	djnz clearEntry

	;a = 0
	ret

error:
	ld a, 1
	ret
#endlocal
