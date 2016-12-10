.z80
.include "biosCalls.h"

.org 0c000h

restart:
	ld e, 0

	call random
	ld d, a
	ld hl, numberPromt
	call print
number:
	xor a
	rst getc
	cp 'q'
	ret z
	xor 30h
	cp 0ah
	jr nc, invalidNumber
	inc e
	cp d
	jr z, equal
	jr c, less
greater:
	ld hl, tooHigh
	call print
	jr attemptsDisp

equal:
	ld hl, correct
	call print
	jr win

less:
	ld hl, tooLow
	call print
	jr attemptsDisp

invalidNumber:
	ld hl, invalid
	call print
	jr number

attemptsDisp:
	ld hl, attempts
	call print
	ld a, e
	or 30h
	rst putc
	ld a, 0dh
	rst putc
	ld a, 0ah
	rst putc
	jr number

win:
	ld hl, attempts
	call print
	ld a, e
	or 30h
	rst putc
	ld a, 0dh
	rst putc
	ld a, 0ah
	rst putc
	ld hl, newGamePromt
	call print
newGame:
	xor a
	call getc
	cp 4eh
	jr z, exit
	cp 6eh
	jr z, exit
	cp 59h
	jr z, restart
	cp 79h
	jp z, restart
	ld hl, invalid
	call print
	jr newGame
exit:
	ret

;*****************
;Random
;
;Description: Puts a random number between 0 and 8 in A
;	      (using the R register)
;
;Inputs: R
;
;Outputs: Random number in A
;
;Destroyed: A, B

random:
	ld a, r
	xor 01010101b
	ld b, a
	sla b
	xor b
	ld b, a
	srl b
	xor b
	ld b, a
	sla b
	sla b
	xor b
	ld b, 5
shiftLoop:
	srl a
	djnz shiftLoop

	ret

;*****************
;Print
;
;Description: Prints a zero-terminated string
;             starting at HL
;
;Inputs: HL
;
;Outputs: String on the Terminal
;
;Destroyed: A, HL

print:
	ld a, (hl)
	inc hl
	cp 00h
	ret z
	rst putc
	jr print
	ret




numberPromt:
	.db "Guess a number from 0 to 7:\r\n"
	.db 0

newGamePromt:
	.db "New Game? y/n\r\n"
	.db 0

correct:
	.db "Correct! "
	.db 0

tooHigh:
	.db "Too high! "
	.db 0

tooLow:
	.db "Too low! "
	.db 0

attempts:
	.db "Attempts: "
	.db 0

invalid: db "Invalid Entry!\r\n"
	.db 0
