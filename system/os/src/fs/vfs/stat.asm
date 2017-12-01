.list

u_stat:

.func k_stat:
;; Get information about a file.
;;
;; Input:
;; : (de) - filename
;; : (hl) - stat
;;
;; Output:
;; : a - errno

	push hl
	ld a, O_RDONLY
	call k_open
	cp 0
	ld a, e
	pop de ;stat
	ret nz

	push af
	call k_fstat
	pop af
	jp k_close
.endf


u_fstat:
	add a, fdTableEntries

.func k_fstat:
;; Get information about an open file.
;;
;; Input:
;; : a - fd
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
	cp 00h
	jr z, invalidFd

	push hl
	pop ix

	;check for valid file driver
	;get the drive table entry of the filesystem
	ld a, (ix + fileTableDriveNumber)
	call getDriveAddr
	jp c, error ;drive number out of bounds
	;(hl) = driveTableEntry
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
	ld hl, fs_fstat
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

.endf
