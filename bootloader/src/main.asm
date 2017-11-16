.z80
.org 0x0000

.define DEBUG

; Jump Table -------------------------------------------------
coldStart:
	jp      _coldStart   ;RST 0x00
	.db     0x00
	jp      0x00         ;CALL 0x04
	.db     0x00
putc:
	jp      _putc        ;RST 0x08
	.db     0x00
	jp      0x00         ;CALL 0x0C
	.db     0x00
getc:
	jp      _getc        ;RST 0x10
	.db     0x00
	jp      0x00         ;CALL 0x14
	.db     0x00
	jp      0x00         ;RST 0x18
	.db     0x00
	jp      0x00         ;CALL 0x1C
	.db     0x00
	jp      0x00         ;RST 0x20
	.db     0x00
	jp      0x00         ;CALL 0x24
	.db     0x00
	jp      0x00         ;RST 0x28
	.db     0x00
	jp      0x00         ;CALL 0x2C
	.db     0x00
	jp      0x00         ;RST 0x30
	.db     0x00
	jp      0x00         ;CALL 0x34
	.db     0x00
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

.ifdef DEBUG
	jr delayLoop
.endif
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
	.asciiz "\n\nBooting OS...\n"


welcomeMsg:
	.asciiz "\nPress any key for boot menu"

bootMenuStr:
	.ascii  "\n\n"
	.ascii  "Select option:\n"
	.ascii  "  1 - Monitor\n"
	.ascii  "  2 - Burn EEPROM\n"
	.ascii  "  3 - Boot into ZI-OS\n"
	.ascii  "  4 - Launch BASIC\n"
	.asciiz "  5 - Selftest\n"

.define FT240_DATA_PORT   0
.define FT240_STATUS_PORT 1

.func _putc:
	push af
poll:
	in a, (FT240_STATUS_PORT)
	bit 0, a
	jr nz, poll
	pop af
	cp '\n'
	call z, newline
	out (FT240_DATA_PORT), a
	ret

newline:
	ld a, '\r'
	out (FT240_DATA_PORT), a
	ld a, '\n'
	ret
.endf

.func _getc:
;; Input:
;; : a - 0=blocking, 1=not blocking
;;
;; Output:
;; : a - data
;; : zf - data available
	or 0
	jr z, blocking
	in a, (FT240_STATUS_PORT)
	bit 1, a
	ret
blocking:
	in a, (FT240_STATUS_PORT)
	bit 1, a
	jr nz, blocking
	in a, (FT240_DATA_PORT)
	cp '\r'
	jr z, blocking
	ret
.endf

.func printStr:
	ld a, (hl)
	cp 00h
	ret z
	rst putc
	inc hl
	jr printStr
.endf

bankSwitch:
	ld a, 0x08
	out (0x02), a
	rst 0
bankSwitchEnd:

romUtil:
.binfile "romutil.bin"
romUtilEnd:
