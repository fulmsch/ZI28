include "biosCalls.h"

	org 0c000h


	ld hl, clearScreenStr
	call printStr
	ld hl, welcomeStr
	call printStr
	
	call resetBoard
	call drawBoard

	
moveEntry:
	;get first coordinate
	xor a
	rst getc
	cp 'q'
	ret z
	rst putc
	cp 64h
	jp nc, invalid
	sub 61h
	jp c, invalid
	ld c, a

	;get second coordinate
	xor a
	rst getc
	cp 'q'
	ret z
	rst putc
	cp 34h
	jp nc, invalid
	sub 31h
	jp c, invalid
	ld b, a
	
	
	
	;calculate boardarray offset	
	ld a, 00h
	ld d, 00h
	ld e, b
	ld hl, offset
	add hl, de
	add hl, de
	jp (hl)
offset:	
	add a, 03h
	add a, 03h
	add a, c
	
	ld hl, boardArray
	ld d, 00h
	ld e, a
	add hl, de
	
	ld a, (hl)
	cp 00h
	jp nz, invalid

	ld a, (currentPlayer)
	add a, 01h
	ld (hl), a
	sub 01h
	xor 01h
	ld (currentPlayer), a
	

	
	call drawBoard

	ld hl, boardArray
	ld b, 9
	
checkFull:	
	ld a, (hl)
	cp 00h
	jp z, moveEntry
	inc hl
	djnz checkFull
	

	ret
 

invalid:
	ld hl, invalidStr
	call printStr
	jr moveEntry


;destroys: b, hl
resetBoard:
	ld b, 9
	ld hl, boardArray
resetBoardLoop:
	ld (hl), 00h
	inc hl
	djnz resetBoardLoop
	ret
	

drawBoard:
	ld a, 0dh
	rst putc
	ld a, 0ah
	rst putc

	ld b, 2
	ld c, 0

	call drawRow
	ld c, 0
	dec b
	
	ld hl, boardStr2
	call printStr
	
	call drawRow
	ld c, 0
	dec b

	ld hl, boardStr2
	call printStr
	
	call drawRow

	ld hl, boardStr3
	call printStr

	ret
	

drawRow:
	ld a, b
	add a, 31h
	rst putc
	ld hl, boardStr0
	call printStr
	
	call drawSymbol
	inc c
	
	ld hl, boardStr1
	call printStr
	
	call drawSymbol
	inc c
	
	ld hl, boardStr1
	call printStr
	
	call drawSymbol
	
	ld a, 0dh
	rst putc
	ld a, 0ah
	rst putc
	
	ret
	
	
	
drawSymbol:
	;calculate boardarray offset	
	ld a, 00h
	ld d, 00h
	ld e, b
	ld hl, drawOffset
	add hl, de
	add hl, de
	jp (hl)
drawOffset:	
	add a, 03h
	add a, 03h
	add a, c
	
	ld hl, boardArray
	ld d, 00h
	ld e, a
	add hl, de
	
	
	ld d, 00h
	ld e, (hl)
	ld hl, symbolArray
	add hl, de
	ld a, (hl)
	rst putc
	ret
	
	
	
	
;Prints a zero-terminated string starting at hl to the port
printStr:
	ld a, (hl)
	cp 00h
	ret z
	rst putc
	inc hl
	jr printStr
	ret


boardStr0:
	db "   "
	db 00h

boardStr1:
	db " | "
	db 00h

boardStr2:
	db "   ---+---+---\r\n"
	db 00h

boardStr3:
	db "\r\n    a   b   c\r\n"
	db 00h


symbolArray:
	db ' ', 'X', 'O'

boardArray:
	db 0, 0, 0
	db 0, 0, 0
	db 0, 0, 0

currentPlayer:
	db 00h

clearScreenStr:
	db 1bh
	db "[2J"
	db 1bh
	db "[H"
	db 00h

welcomeStr:
	db "Tic-Tac-Toe v0.2\r\n"
	db "(c) F.Ulmschneider 2016\r\n"
	db 00h

invalidStr:
	db "Invalid entry\r\n"
	db 00h
