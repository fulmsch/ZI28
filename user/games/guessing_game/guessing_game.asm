INCLUDE "asm/os.h"

ORG MEM_user

restart:
	ld e, 0

	call random
	ld d, a
	ld hl, numberPromt
	call print
number:
	xor a
	rst RST_getc
	cp 'q'
	jr z, exit
	cp 0x03 ;ctrl-c
	jr z, exit
	xor 0x30
	cp 0x0a
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
	or 0x30
	rst RST_putc
	ld a, 0x0a
	rst RST_putc
	jr number

win:
	ld hl, attempts
	call print
	ld a, e
	or 30h
	rst RST_putc
	ld a, 0x0a
	rst RST_putc
	ld hl, newGamePromt
	call print
newGame:
	xor a
	rst RST_getc
	cp 0x4e
	jr z, exit
	cp 0x6e
	jr z, exit
	cp 0x59
	jr z, restart
	cp 0x79
	jp z, restart
	ld hl, invalid
	call print
	jr newGame
exit:
	ld c, SYS_exit
	xor a
	rst RST_syscall

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
	cp 0x00
	ret z
	rst RST_putc
	jr print
	ret




numberPromt:
	DEFM "Guess a number from 0 to 7:\n", 0x00

newGamePromt:
	DEFM "New Game? y/n\n", 0x00

correct:
	DEFM "Correct! ", 0x00

tooHigh:
	DEFM "Too high! ", 0x00

tooLow:
	DEFM "Too low! ", 0x00

attempts:
	DEFM "Attempts: ", 0x00

invalid:
	DEFM "Invalid Entry!\n", 0x00
lbl invalid
