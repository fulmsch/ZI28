.list

.func udup:
;; Copy a kernel file descriptor to the user fd-table.
;;
;; If the user fd already exists, it will stay the same.
;;
;; Input:
;; : a - user fd
;; : b - kernel fd
;;
;; Output:
;; : a - errno

	push af
	ld a, b
	call getFdAddr
	jr c, error
	;hl = kernel fd addr
	pop af ;user fd
	add a, fdTableEntries
	push hl ;kernel fd addr
	call getFdAddr
	jr c, error
	pop de ;kernel fd addr
	;hl = user fd addr

	;check if user fd already exists
	ld a, (hl)
	cp 0xff
	ld a, 0
	ret nz

	;copy fd
	ld a, (de)
	ld (hl), a
	;inc reference count
	call getFileAddr
	inc hl
	inc (hl)

	xor a
	ret


error:
	pop af
	ld a, 1
	ret

.endf
