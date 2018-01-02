SECTION rom_code
PUBLIC devfs_addExpCard

EXTERN devfs_addDev

devfs_addExpCard:
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

	ld a, 0x80
portLoop:
	add a, 16
	djnz portLoop
portFound:
	
	call devfs_addDev
	jr c, error

error:
	ret
