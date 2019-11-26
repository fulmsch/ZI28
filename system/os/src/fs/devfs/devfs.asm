#define devfs_name         0
#define devfs_entryDriver  8
#define devfs_number      10
#define devfs_data        11

#define dev_fileTableDirEntry fileTableData ;Pointer to entry in devfs
#define dev_fileTableNumber   dev_fileTableDirEntry + 2
#define dev_fileTableData     dev_fileTableNumber + 1

#define devfsEntrySize 16
#define devfsEntries   32

;; Device filesystem
#code ROM

devfs_fsDriver:
	DEFW devfs_init
	DEFW devfs_open
	DEFW 0x0000 ;devfs_close
	DEFW devfs_readdir
	DEFW devfs_fstat
	DEFW 0x0000 ;devfs_unlink

devfs_fileDriver:
	DEFW 0x0000 ;devfs_read
	DEFW 0x0000 ;devfs_write


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

#local
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
#endlocal


devfs_addExpCard:
;; Add an entry for an expansion card to the devfs and initialise the module.
;; Should eventually also read the eeprom and handle driver loading somehow.
;;
;; Input:
;; : b - expansion slot number
;; : de - device driver (temporary)

#local
	;TODO check if card is inserted; read the eeprom; evt. load driver; needs unio driver

	;calculate port
	;port = $80 + n * 16
	xor a
	cp b
	jr z, portFound
	ld a, 7
	cp b
	jr c, error ;invalid slot number

	ld a, 0x80
portLoop:
	add a, 16
	djnz portLoop
portFound:

	call devfs_addDev
	jr c, error

error:
	ret
#endlocal


devfs_scanPartitions:
;; Check if a block device is partioned and add each partition to :DEV/.
;;
;; Open device, check if partitioned, read partition table
;; Copy existing entry, add number to name, add offset (driver agnostic?)
;;
;; Input:
;; : (hl) - name of base device


devfs_statFromEntry:
;; Creates a stat from a directory entry.
;;
;; Input:
;; : (hl) - dir entry
;; : (de) - stat

	;copy name
	push de
	call strcpy
	pop de
	ex de, hl
	;(hl) = stat, (de) = dirEntry
	ld bc, STAT_ATTRIB
	add hl, bc
	;(hl) = stat_attrib
	;TODO store actual attribs
	ld (hl), SP_READ | SP_WRITE | ST_CHAR

	;file size is unspecified

	xor a
	ret


#data RAM
devfsRoot:           defs devfsEntrySize * devfsEntries
devfsRootTerminator: defs 1

#include "init.asm"
#include "fstat.asm"
#include "open.asm"
#include "readdir.asm"
