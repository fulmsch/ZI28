;TODO change putc and getc to OS equivalents

include "biosCalls.h"

cliStart: equ 0c000h


	org cliStart


.prompt:
	ld hl, .promptPlaceholder
	call printStr
	ld a, ':'
	call putc
	ld a, ' '
	call putc
	;call exit


	ld hl, .inputBuffer
	ld c, 0
.handleChar:
	;TODO navigation with arrow keys
	xor a
	call getc
	cp 08h
	jr z, .backspace
	cp 0dh
	jr z, .handleLine
	;Check if printable
	cp 20h
	jr c, .handleChar
	cp 7fh
	jr nc, .handleChar
	ld (hl), a
	call putc
	;Check for buffer overflow
	inc c
	ld a, c
	cp .inputBufferSize
	jr nc, .inputBufferOverflow
	inc hl
	jr .handleChar

.backspace:
	ld a, c
	cp 0
	jr z, .handleChar
	ld a, 08h
	call putc
	ld a, 20h
	call putc
	ld a, 08h
	call putc
	dec hl
	dec c
	jr .handleChar

.inputBufferOverflow:
	ld hl, .inputBufferOverflowStr
	call printStr
	ret

.inputBufferOverflowStr:
	db "\r\nThe entered command is too long\r\n"
	db 00h

.handleLine:
	ld a, 0dh
	call putc
	ld a, 0ah
	call putc
	;TODO store history in file

	ld (hl), 00h
	ld hl, .inputBuffer
	ld de, argv
	ld a, 00h
	ld (argc), a

	;break the input into individual strings
	ld a, (hl)
	cp 00h
	jr z, .commandDispatch;finished the input string
	cp ' '
	jr z, .nextArgSpace
	call .addArg
	inc hl

.nextArg:
	ld a, (hl)
	cp 00h
	jr z, .commandDispatch;finished the input string
	cp ' '
	jr z, .nextArgSpace
	inc hl
	jr .nextArg

.nextArgSpace:
	ld a, 00h
	ld (hl), a
	inc hl
	ld a, (hl)
	cp ' '
	jr z, .nextArgSpace
	call .addArg
	jr .nextArg

.addArg:
	;increment argc
	ld a, (argc)
	inc a
	cp .maxArgc + 1
	jr nc, .argOverflow;too many arguments
	ld (argc), a

	ld a, l
	ld (de), a
	inc de
	ld a, h
	ld (de), a
	inc de
	ret

.argOverflow:
	ld hl, .argOverflowStr
	call printStr
	pop hl
	jp .prompt

.argOverflowStr:
	db "\r\nToo many arguments\r\n"
	db 00h

.commandDispatch:
	ld a, (argc)
	cp 00h
	jp z, .prompt
	ld b, a
	ld de, argv

	;convert first command to uppercase
	ld a, (de)
	ld l, a
	inc de
	ld a, (de)
	ld h, a
	push hl
	call .convertToUpper
	dec de

	;test: print out all arguments
;.argLoop:
;	ld a, (de)
;	ld l, a
;	inc de
;	ld a, (de)
;	ld h, a
;	inc de
;	call printStr
;	ld a, 0dh
;	call putc
;	ld a, 0ah
;	call putc
;	djnz .argLoop

	ld bc, .dispatchTable
	pop hl ;contains pointer to first string
.dispatchLoop:
	ld a, (bc)
	ld e, a
	inc bc
	ld a, (bc)
	ld d, a
	inc bc
	inc bc
	inc bc
	ld a, (de)
	cp 00h
	jr z, .noMatch
	push bc
	push hl
	call .strCompare
	pop hl
	pop bc
	jr nz, .dispatchLoop;no match

	;match, jump to builtin function
	dec bc
	ld a, (bc)
	ld h, a
	dec bc
	ld a, (bc)
	ld l, a
	ld de, .prompt
	push de
	jp (hl)


.noMatch:
	;TODO check path for programs
	ld hl, .noMatchStr
	call printStr
	jp .prompt

.noMatchStr:
	db "Command not recognised\r\n"
	db 00h


.maxArgc: equ 32
argc:
	db 0
argv:
	ds .maxArgc*2

.promptPlaceholder:
	db "/HOME/DOCUMENTS/EXAMPLE"
	db 00h

.inputBufferSize: equ 128
.inputBuffer:
	ds .inputBufferSize

;Command strings
.echoStr:	db "ECHO\0"
.exitStr:	db "EXIT\0"
.monStr:	db "MON\0"
.nullStr:	db "\0"

.dispatchTable:
	dw .echoStr, echo
	dw .exitStr, exit
	dw .monStr, cliMonitor
	dw .nullStr


;****************
;String Compare
;Description: Compares two strings
;Inputs: de, hl: String pointers
;Outputs: z if equal strings
;Destroyed: a, b
.strCompare:
	ld a, (de)
	ld b, a
	ld a, (hl)
	cp b
	ret nz
	cp 00h
	ret z
	inc de
	inc hl
	jr .strCompare


;*****************
;ConvertToUpper
;Description: Converts a string to uppercase
;Inputs: hl: String pointer
;Outputs:
;Destroyed: none
.convertToUpper:
	ld a, (hl)
	cp 0
	ret z

	cp 61h
	jr c, .convertToUpper00
	cp 7bh
	jr nc, .convertToUpper00
	sub 20h
	ld (hl), a
.convertToUpper00:
	inc hl
	jr .convertToUpper


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


include "builtins.asm"
