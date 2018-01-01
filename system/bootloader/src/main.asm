ORG 0x0000

DEFINE DEBUG

; Jump Table -------------------------------------------------
coldStart:
	jp      _coldStart   ;RST 0x00
	DEFB    0x00
	jp      0x00         ;CALL 0x04
	DEFB    0x00
putc:
	jp      _putc        ;RST 0x08
	DEFB    0x00
	jp      0x00         ;CALL 0x0C
	DEFB    0x00
getc:
	jp      _getc        ;RST 0x10
	DEFB    0x00
	jp      0x00         ;CALL 0x14
	DEFB    0x00
	jp      0x00         ;RST 0x18
	DEFB    0x00
	jp      0x00         ;CALL 0x1C
	DEFB    0x00
	jp      0x00         ;RST 0x20
	DEFB    0x00
	jp      0x00         ;CALL 0x24
	DEFB    0x00
	jp      0x00         ;RST 0x28
	DEFB    0x00
	jp      0x00         ;CALL 0x2C
	DEFB    0x00
	jp      0x00         ;RST 0x30
	DEFB    0x00
	jp      0x00         ;CALL 0x34
	DEFB    0x00
	jp      0x00         ;RST 0x38


_coldStart:
	ld sp, 0x8000
	ld hl, welcomeMsg
	call printStr

	ld bc, 0x1000
	ld d, 5
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
	rst getc
	jr z, bootMenu
	djnz delayLoop
	ld a, '.'
	rst putc
	dec d
	jr nz, delayLoop

IFDEF DEBUG
	jr delayLoop
ENDIF
	jr bootOS

bootMenu:
	ld a, 1
	rst getc
	jr nz, emptyBuffer
	xor a
	rst getc
emptyBuffer:
	ld hl, bootMenuStr
	call printStr
bootMenuLoop:
	xor a
	rst getc
	cp '1'
	cp '2'
	jr z, loadRomUtil
	cp '3'
	jr z, bootOS
	cp '4'
	cp '5'
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


welcomeMsg:
	DEFM "\nPress any key for boot menu", 0x00

bootMenuStr:
	DEFM  "\n\n"
	DEFM  "Select option:\n"
	DEFM  "  1 - Monitor\n"
	DEFM  "  2 - Burn EEPROM\n"
	DEFM  "  3 - Boot into ZI-OS\n"
	DEFM  "  4 - Launch BASIC\n"
	DEFM "  5 - Selftest\n", 0x00

DEFC FT240_DATA_PORT   = 0
DEFC FT240_STATUS_PORT = 1

_putc:
	push af
_putc_poll:
	in a, (FT240_STATUS_PORT)
	bit 0, a
	jr nz, _putc_poll
	pop af
	cp '\n'
	call z, _putc_newline
	out (FT240_DATA_PORT), a
	ret
_putc_newline:
	ld a, '\r'
	out (FT240_DATA_PORT), a
	ld a, '\n'
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
	cp '\r'
	jr z, _getc_blocking
	ret


printStr:
	ld a, (hl)
	cp 00h
	ret z
	rst putc
	inc hl
	jr printStr


bankSwitch:
	ld a, 0x08
	out (0x02), a
	rst 0
bankSwitchEnd:

romUtil:
BINARY "romutil.bin"
romUtilEnd:
