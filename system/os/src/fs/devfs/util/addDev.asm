SECTION rom_code
INCLUDE "devfs.h"

PUBLIC devfs_addDev

devfs_addDev:
;; Add a new device entry
;;
;; Input:
;; : (hl) - name
;; : de - driver address
;; : a - number / port
;;
;; Output:
;; : carry - unable to create entry
;; : nc - no error
;; : hl - custom data start

	push af
	push de
	push hl

	;find free entry
	ld a, 0
	ld hl, devfsRoot
	ld de, devfsEntrySize
	ld b, devfsEntries

findEntryLoop:
	cp (hl)
	jr z, freeEntryFound
	add hl, de
	djnz findEntryLoop

	;no free entry found
	pop hl
	pop hl
	pop hl
	scf
	ret

freeEntryFound:
	;hl = entry

	;copy filename
	pop de ;name
	ex de, hl
	ld bc, 8
	ldir
	ex de, hl

	;register driver address
	pop de ;driver address
	ld b, d
	ld c, e
	;bc = device driver
	inc de
	inc de
	;de = file driver
	ld (hl), e
	inc hl
	ld (hl), d
	inc hl

	;dev number
	pop af
	ld (hl), a
	inc hl

	push hl ;custom data start

	;call init function if it exists
	ld a, (bc)
	ld l, a
	inc bc
	ld a, (bc)
	ld h, a
	xor a
	cp h
	jr nz, callInit
	cp l
	jr z, return
callInit:
	ld bc, return
	push bc
	jp (hl)
return:

	pop hl ;custom data start

	or a
	ret
