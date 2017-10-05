.list

.func u_dup:
	ld hl, u_fdTable
	ld c, fdTableEntries
	call dup
	; e -= fdTableEntries
	push af
	ld a, e
	sub fdTableEntries
	ld e, a
	pop af
	ret
.endf

k_dup:
;; Duplicate a file descriptor.
;;
;; If `new fd` is equal to 0xFF, the next free file descriptor will be used.
;;
;; Input:
;; : a - new fd
;; : b - old fd
;;
;; Output:
;; : a - errno
;; : e - new fd

	ld hl, k_fdTable
	ld c, 0

.func dup:
;; Input:
;; : a - new fd
;; : b - old fd
;; : hl - base address of fd-table
;; : c - base fd
;;
;; Output:
;; : a - errno
;; : e - new fd

	push af
	ld a, b
	ld (k_dup_oldFd), a
	pop af

	cp 0xff
	jr nz, newSpecified

	ld a, 0xff
	ld b, fdTableEntries
fdSearchLoop:
	cp (hl)
	jr z, newFdFound
	inc c
	inc hl
	djnz fdSearchLoop

	jr error

newFdFound:
	ld a, c
	ld (k_dup_newFd), a
	jr copyFd

newSpecified:
	ld (k_dup_newFd), a
	call getFdAddr
	jr c, error
	ld a, (hl)
	cp 0xff
	jr z, copyFd
	call k_close

copyFd:
	ld a, (k_dup_newFd)
	call getFdAddr
	push hl
	ld a, (k_dup_oldFd)
	call getFdAddr
	pop de
	jr c, error
	;de - new fd, hl - old fd
	ld a, (hl)
	ld (de), a

	;inc reference count
	ld a, (hl)
	call getFileAddr
	inc hl
	inc (hl)

	ld a, (k_dup_newFd)
	ld e, a

	xor a
	ret

error:
	ld a, 1
	ret
.endf
