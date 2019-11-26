#code ROM

_coldStart:
	cp 0
	jr nz, _warmStart

	ld sp, 0x8000

	ld hl, nameStr
	call printStr
	ld hl, coldStartStr
	call printStr
	ld hl, bootMenuStr
	call printStr

	ld bc, 0x1000
	ld d, 3
delayLoop:
	ex (sp), hl
	ex (sp), hl
	ex (sp), hl
	ex (sp), hl
	ex (sp), hl
	ex (sp), hl
	dec c
	jr nz, delayLoop
	ld a, 1
	rst RST_getc
	jr z, bootMenu
	djnz delayLoop
	dec d
	jr nz, delayLoop

	jr bootOS


_warmStart:
	ld sp, 0x8000

	ld hl, nameStr
	call printStr
	ld hl, warmStartStr
	call printStr
	ld hl, bootMenuStr
	call printStr
	jr bootMenuLoop

bootMenu:
	ld hl, bootAbortStr
	call printStr

bootMenuLoop:
	xor a
	rst RST_getc
	cp '1'
	jr z, bootOS
	cp '2'
	;jp z, monitor
	cp '3'
	;jp z, basic
	cp '4'
	jr z, loadRomUtil
	jr bootMenuLoop

loadRomUtil:
	ld hl, romUtil
	ld de, 0x8000
	ld bc, romUtilEnd - romUtil
	ldir
	jp 0x8000


bootOS:
	ld hl, bootOSstr
	call printStr
	ld hl, bankSwitch
	ld de, 0x8000
	ld bc, bankSwitchEnd - bankSwitch
	ldir
	jp 0x8000

bootOSstr:
	DEFM "\n\nBooting OS...\n", 0x00

nameStr:
	DEFM "\n##############   ZI-28 Boot Menu V0.0   ##############\n"
	DEFM "\n", 0x00

coldStartStr:
	DEFM "Press any key to stop automatic boot or select option:\n", 0x00

warmStartStr:
	DEFM "Select option:\n", 0x00

bootMenuStr:
	DEFM "  [1] Boot ZI-OS\n"
	DEFM "  [2] Monitor\n"
	DEFM "  [3] Launch BASIC\n"
	DEFM "  [4] Burn EEPROM\n", 0x00

bootAbortStr:
	DEFM "\nAutomatic boot aborted\n", 0x00


#define FT240_DATA_PORT   0
#define FT240_STATUS_PORT 1

_putc:
	push af
_putc_poll:
	in a, (FT240_STATUS_PORT)
	bit 0, a
	jr nz, _putc_poll
	pop af
	cp 0x0a ;'\n'
	call z, _putc_newline
	out (FT240_DATA_PORT), a
	ret
_putc_newline:
	ld a, 0x0d ;'\r'
	out (FT240_DATA_PORT), a
	ld a, 0x0a ;'\n'
	ret


_getc:
;; Input:
;; : a - 0=blocking, 1=not blocking
;;
;; Output:
;; : a - data
;; : zf - data available
	or 0
	jr z, _getc_blocking
	in a, (FT240_STATUS_PORT)
	bit 1, a
	ret
_getc_blocking:
	in a, (FT240_STATUS_PORT)
	bit 1, a
	jr nz, _getc_blocking
	in a, (FT240_DATA_PORT)
	cp 0x0d ;'\r'
	jr z, _getc_blocking
	ret


printStr:
	ld a, (hl)
	cp 00h
	ret z
	rst RST_putc
	inc hl
	jr printStr


bankSwitch:
	ld a, 0x08
	out (0x02), a
	jp 0
bankSwitchEnd:

romUtil:
	incbin "../romutil.bin"
romUtilEnd:
