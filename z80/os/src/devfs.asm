;; Device filesystem
.list

.define devfs_name         0
.define devfs_entryDriver  8
.define devfs_number      10
;.define devfs_attributes  11
.define devfs_data        11


devfs_fsDriver:
	.dw devfs_init
	.dw devfs_open
	.dw devfs_close

.define dev_fileTableNumber fileTableData
.define dev_fileTableData   dev_fileTableNumber + 1


.func devfs_init:
;; Adds all permanently attached devices

	;ft240
	ld hl, tty0name
	ld de, ft240_fileDriver
	ld a, 0
	call devfs_addDev

	ld hl, sdaName
	ld de, sd_fileDriver
	ld a, 0
	call devfs_addDev

	xor a
	ret


tty0name:
	.asciiz "TTY0"
sdaName:
	.asciiz "SDA"
.endf ;devfs_init


.func devfs_addDev:
;; Add a new device entry
;;
;; Input:
;; : (hl) - name
;; : de - driver address
;; : a - number
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
	ld bc, devfsEntries

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
	ld (hl), e
	inc hl
	ld (hl), d
	inc hl

	;dev number
	pop af
	ld (hl), a
	inc hl

	or a
	ret
.endf


.func devfs_open:
;; Open a device file
;;
;; Input:
;; : ix - table entry
;; : (de) - absolute path
;; : a - mode
;;
;; Output:
;; : a - errno

; Errors: 0=no error
;         4=no matching file found

	ld hl, devfsRoot
	push de ;path
	push hl ;file entry
	ld b, 8
	call strncmp
	jr z, fileFound

fileSearchLoop:
	ld de, devfsEntrySize
	pop hl ;file entry
	add hl, de
	pop de ;path
	ld a, (hl)
	cp 0
	jr z, invalidFile
	push de ;path
	push hl ;file entry
	ld b, 8
	call strncmp
	jr nz, fileSearchLoop

fileFound:
	pop iy ;pointer to devfs file entry
	pop de ;path, not needed anymore

	;copy file information
	ld a, (iy + devfs_entryDriver)
	ld (ix + fileTableDriver), a
	ld a, (iy + devfs_entryDriver + 1)
	ld (ix + fileTableDriver + 1), a

	;fill table spot
	ld (ix + 0), 1

	;operation succesful
	xor a
	ret

invalidFile:
	ld a, 4
	ret
.endf ;devfs_open


.func devfs_close:

	ret
.endf ;devfs_close
