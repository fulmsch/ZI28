SECTION rom_code
INCLUDE "string.h"
INCLUDE "drive.h"

PUBLIC get_drive_and_path

get_drive_and_path:
;; Get the drive number and relative path from an absolute path.
;;
;; Input:
;; : (hl) - absolute path
;;
;; Output:
;; : (hl) - relative path to fs root
;; : (de) - drive entry
;; : carry - error

	ld a, (hl)
	cp '/'
	scf
	ret nz ;path must begin with '/'

	ld de, driveTable
	ld b, 0xff ;parent

traverseTree:
	ld a, (hl)
	cp 0
	jr z, parentEnd
	push de ;drive entry
	push hl ;path
	inc d ;mount table
	call strbegins ;does the path begin with the current mount point?
	jr z, nextChild
	ld a, (hl)
	cp 0
	jr nz, nextSibling
	pop de ;path
	pop hl ;drive entry
	push hl
	push de
	inc h ;mount table
	call strbegins ;does the current mount point begin with the path?
	jr nz, nextSibling
	ld a, (hl)
	cp '/'
	jr nz, nextSibling
	inc hl
	ld a, (hl)
	cp 0x00
	jr nz, nextSibling
	ex de, hl

nextChild:
	pop de ;old path, discard
	pop de ;drive entry

	ld a, (de) ;child
	cp 0xff
	jr z, end
	ld b, e ;save e as parent
	ld e, a
	jr traverseTree


nextSibling:
	pop hl ;path
	pop de ;drive entry

	inc de ;point to sibling
	ld a, (de)
	cp 0xff
	jr z, parentEnd
	ld e, a ;sibling
	jr traverseTree

parentEnd:
	ld e, b
end:
	;error if e == 0xff
	inc e
	ret c
	dec e
	ret
