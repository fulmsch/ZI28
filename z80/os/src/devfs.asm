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

	;copy filename
	ld de, devfsRoot
	ld hl, tty0name
	ld bc, 8
	ldir
	;register driver address
	ld hl, ft240_fileDriver
	ld a, l
	ld (de), a
	inc de
	ld a, h
	ld (de), a
	inc de
	;dev number
	ld a, 0
	ld (de), a
	inc de
	;attributes (char, rw)
	ld (de), a
	inc de
	;reserved bytes
	inc de
	inc de
	inc de
	inc de

	;copy filename
	ld hl, sdaName
	ld bc, 8
	ldir
	;register driver address
	ld hl, sd_fileDriver
	ld a, l
	ld (de), a
	inc de
	ld a, h
	ld (de), a
	inc de
	;dev number
	ld a, 0
	ld (de), a
	inc de
	;attributes (char, rw)
	ld (de), a
	inc de
	;reserved bytes
	inc de
	inc de
	inc de
	inc de

	;end of devfs
	ld hl, devfsRootTerminator
	ld (hl), 0


	xor a
	ret


tty0name:
	.asciiz "TTY0"
sdaName:
	.asciiz "SDA"
.endf ;devfs_init


.func devfs_open:
;; Inputs: ix = table entry, (de) = absolute path, a = mode
;; Outputs: a = errno
;; Errors: 0=no error
;;         4=no matching file found

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
