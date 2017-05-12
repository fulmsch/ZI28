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
	.dw devfs_readdir

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

	ld hl, sda1Name
	ld de, sd_fileDriver
	ld a, 1
	call devfs_addDev
	call clear32
	ld a, 89h
	call ld8

	xor a
	ret


tty0name:
	.asciiz "TTY0"
sdaName:
	.asciiz "SDA"
sda1Name:
	.asciiz "SDA1"
.endf ;devfs_init


.func devfs_addDev:
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

.func devfs_addExpCard:
;; Add an entry for an expansion card to the devfs and initialise the module.
;; Should eventually also read the eeprom and handle driver loading somehow.
;;
;; Input:
;; : b - expansion slot number
;; : de - device driver (temporary)

	;TODO check if card is inserted; read the eeprom; evt. load driver; needs unio driver

	;calculate port
	;port = $80 + n * 16
	xor a
	cp b
	jr z, portFound
	ld a, 7
	cp b
	jr c, error ;invalid slot number

	ld a, 80h
portLoop:
	add a, 16
	djnz portLoop
portFound:
	
	call devfs_addDev
	jr c, error

error:
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

	ld a, (iy + devfs_number)
	ld (ix + dev_fileTableNumber), a

	;copy custom data
	ld bc, devfsEntrySize - devfs_data
	ld d, ixh
	ld e, ixl
	ld hl, dev_fileTableData
	add hl, de
	push hl
	ld d, iyh
	ld e, iyl
	ld hl, devfs_data
	add hl, de
	pop de
	ldir

	;store filetype TODO add distincion between char and block devs
	ld a, (ix + fileTableMode)
	or 1 << M_CHAR
	ld (ix + fileTableMode), a

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


.func devfs_readdir:

	ret
.endf


.func devfs_fstat:

	ret
.endf
