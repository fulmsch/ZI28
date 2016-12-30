SD_ENABLE: macro
	out (82h), a
	endm

SD_DISABLE: macro
	out (83h), a
	endm

delay100:
	;Wait for approx. 100ms
	ld b, 0
	ld c, 41
delay100Loop:
	ex (sp), hl
	ex (sp), hl
	ex (sp), hl
	ex (sp), hl
	djnz delay100Loop
	dec c
	jr nz, delay100Loop
	ret


sdInitStr:
	db "Initialising SD-Card\r\n\0"

noCardStr:
	db "Error: no card detected\r\n\0"

sdSuccessStr:
	db "Success\r\n\0"


sdInit:
	ld hl, sdInitStr
	call printStr

	SD_DISABLE

	;Send 80 clock pulses
	ld b, 10
.sdInit00:
	out (81h), a
	djnz .sdInit00

	SD_ENABLE

	ld a, 40h
	out (80h), a
	out (81h), a
	ld a, 00h
	out (80h), a
	out (81h), a
	out (80h), a
	out (81h), a
	out (80h), a
	out (81h), a
	out (80h), a
	out (81h), a
	ld a, 95h
	out (80h), a
	out (81h), a

	ld b, 8
.sdInit01:
	;Look for a 01h response
	out (81h), a
	nop
	nop
	in a, (80h)
	cp 01h
	jr z, .sdInit02
	djnz .sdInit01

	SD_DISABLE

	ld a, '1'
	rst putc
	ld hl, noCardStr
	jp printStr


.sdInit02:
	out (81h), a
	nop
	nop
	in a, (80h)
	djnz .sdInit02

	SD_DISABLE


sdCmd41:
	SD_ENABLE

	ld a, 41h
	ld bc, 0
	ld de, 0
	call sdSendCmd

	ld b, 8
.sdInit03:
	out (81h), a
	nop
	nop
	in a, (80h)
	djnz .sdInit03

	SD_DISABLE

	call delay100

	SD_ENABLE

	ld a, 41h
	ld bc, 0
	ld de, 0
	call sdSendCmd


.sdInit04:
	;Look for a 00h response
	out (81h), a
	nop
	nop
	in a, (80h)
	cp 00h
	jr z, .sdInit05
	djnz .sdInit04

	SD_DISABLE

	ld a, '2'
	rst putc
	ld hl, noCardStr
	jp printStr


.sdInit05:
	out (81h), a
	nop
	nop
	in a, (80h)
	djnz .sdInit05

	SD_DISABLE


sdCmd50:
	SD_ENABLE

	ld a, 50h
	ld bc, 0002h
	ld de, 0000h
	call sdSendCmd

	ld b, 8
.sdInit06:
	out (81h), a
	nop
	nop
	in a, (80h)
	djnz .sdInit06

	SD_DISABLE

	ld hl, sdSuccessStr
	call printStr

	ret



_sdRead:
	;test values
	;ld a, 1
	;ld bc, 0012h
	;ld de, 0100h
	;ld hl, 4200h

	push af

	SD_ENABLE

	ld a, 52h
	call sdSendCmd

;Wait for cmd response
	ld b, 10
.sdWaitCmd:
	out (81h), a
	nop
	nop
	in a, (80h)
	cp 00h
	jr z, .sdWaitDataToken
	djnz .sdWaitCmd

	SD_DISABLE
	pop af
	ld a, '1'
	call putc
	ret


sdReadSector:
;Wait for data packet start
.sdWaitDataToken:
	ld b, 100
.sdRead02:
	out (81h), a
	nop
	nop
	in a, (80h)
	cp 0feh
	jr z, .sdReadDataBlock
	djnz .sdRead02

	SD_DISABLE
	pop af
	ld a, '2'
	call putc
	ret

.sdReadDataBlock:
	ld b, 0
.sdRead04:
	out (81h), a
	nop
	nop
	in a, (80h)
	ld (hl), a
	inc hl
	djnz .sdRead04
.sdRead05:
	out (81h), a
	nop
	nop
	in a, (80h)
	ld (hl), a
	inc hl
	djnz .sdRead05

;Receive the crc and discard it
	ld b, 2
.sdGetCrc:
	out (81h), a
	nop
	nop
	in a, (80h)
	djnz .sdGetCrc

	pop af
	dec a
	push af
	jr nz, sdReadSector

	pop af
	ld a, 4ch
	ld bc, 0
	ld de, 0
	call sdSendCmd

	out (81h), a


	ld b, 100
.sdRead06:
	out (81h), a
	nop
	nop
	in a, (80h)
	cp 0ffh
	jr z, .sdRead07
	djnz .sdRead06

.sdRead07:
	SD_DISABLE

	ret



sdSendCmd:
; a: Command
; edcb: Argument

	out (80h), a
	out (81h), a
	ld a, e
	out (80h), a
	out (81h), a
	ld a, d
	out (80h), a
	out (81h), a
	ld a, c
	out (80h), a
	out (81h), a
	ld a, b
	out (80h), a
	out (81h), a
	ld a, 0ffh
	out (80h), a
	out (81h), a
	ret

