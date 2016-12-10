;**************************
;SD-Card bootloader
;Florian Ulmschneider 2016


.z80
.include "biosCalls.h"

.define stage1Addr 0c000h
.define stage2Addr stage1Addr + 200h

.define partitionTableStart stage1Addr + 1beh
.define partitionEntrySize 10h
.define partitionTypeOffset 04h
.define partitionStartSectorOffset 08h
.define partitionSizeOffset 0ch

.org stage1Addr

	;required for bootloader recognition by bios
	jr start
start:

	ld sp, 8000h

	ld hl, chooseStr
	call printStr

	;check 1beh if bootable
	ld c, 0
	ld b, 4
	ld de, partitionSectorTable
	ld ix, partitionTableStart
checkBootableLoop:
	ld a, (ix+0)
	cp 80h
	call z, bootableEntry
	ld de, partitionEntrySize
	add ix, de
	djnz checkBootableLoop


	ld a, 0dh
	call putc
	ld a, 0ah
	call putc

	ld a, c
	or 30h
	add a, 1
	ld c, a


inputLoop:
	xor a
	call getc
	cp 30h
	jp z, monitor
	jr c, inputLoop
	cp c
	jr nc, inputLoop

	and 0fh
	dec a
	add a, a
	add a, a
	ld h, 0
	ld l, a
	ld de, partitionSectorTable
	add hl, de

	ld b, 0
	ld c, (hl)
	inc hl
	ld d, (hl)
	inc hl
	ld e, (hl)

	sla c
	rl d
	rl e

	ld a, 1
	ld hl, stage2Addr
	rst sdRead

	jp stage2Addr


bootableEntry:
	inc c
	ld hl, entryStr
	call printStr
	ld a, c
	or 30h
	call putc
	ld hl, entryStr2
	call printStr

	;print partition type
	ld a, (ix+partitionTypeOffset)
	ld hl, fat16Str
	cp 06h
	jr z, printPartitionType
	ld hl, unknownPartitionTypeStr

printPartitionType:
	call printStr
	;print partition size

	;store partition start sector
	ld a, (ix+partitionStartSectorOffset)
	ld (de), a
	inc de
	ld a, (ix+partitionStartSectorOffset+1)
	ld (de), a
	inc de
	ld a, (ix+partitionStartSectorOffset+2)
	ld (de), a
	inc de
	ld a, (ix+partitionStartSectorOffset+3)
	ld (de), a
	inc de

	ret


partitionSectorTable:
	.resb 16

chooseStr:
	.db "\r\nChoose boot option:"
	.asciiz "\r\n[0]: Monitor"

entryStr:
	.asciiz "\r\n["
entryStr2:
	.asciiz "]: "

unknownPartitionTypeStr:
	.asciiz "Unknown partition type"
fat16Str:
	.asciiz "FAT16"


;*****************
;PrintString
;Description: Prints a zero-terminated string starting at hl to the terminal
;Inputs: String starting at (hl)
;Outputs: String at terminal
;Destroyed: hl, a
printStr:
	ld a, (hl)
	cp 00h
	ret z
	call putc
	inc hl
	jr printStr
