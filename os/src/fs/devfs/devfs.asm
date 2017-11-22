;; Device filesystem
.list

devfs_fsDriver:
	.dw devfs_init
	.dw devfs_open
	.dw 0x0000 ;devfs_close
	.dw devfs_readdir
	.dw devfs_fstat
	.dw 0x0000 ;devfs_unlink

devfs_fileDriver:
	.dw 0x0000 ;devfs_read
	.dw 0x0000 ;devfs_write


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

.include "fs/devfs/init.asm"
.include "fs/devfs/open.asm"
.include "fs/devfs/readdir.asm"
.include "fs/devfs/fstat.asm"
