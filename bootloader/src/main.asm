.z80
.org 0x0000

; Jump Table -------------------------------------------------
coldStart:
	jp      _coldStart   ;RST 00h
	.db     0x00
	jp      0x00         ;CALL 04h
	.db     0x00
putc:
	jp      _putc        ;RST 08h
	.db     0x00
	jp      0x00         ;CALL 0Ch
	.db     0x00
getc:
	jp      _getc        ;RST 10h
	.db     0x00
	jp      0x00         ;CALL 14h
	.db     0x00
	jp      0x00         ;RST 18h
	.db     0x00
	jp      0x00         ;CALL 1Ch
	.db     0x00
	jp      0x00         ;RST 20h
	.db     0x00
	jp      0x00         ;CALL 24h
	.db     0x00
	jp      0x00         ;RST 28h
	.db     0x00
	jp      0x00         ;CALL 2Ch
	.db     0x00
	jp      0x00         ;RST 30h
	.db     0x00
	jp      0x00         ;CALL 34h
	.db     0x00
	jp      0x00         ;RST 38h


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
	cp '3'
	jr z, bootOS
	cp '4'
	cp '5'
	jr bootMenuLoop


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
