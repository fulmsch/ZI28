;TODO change putc and getc to OS equivalents

.z80
.include "biosCalls.h"
.include "bcosCalls.h"

.define cliStart 6000h


.define inputBufferSize 128
.define maxArgc 32


.org cliStart

prompt:
;	ld hl, promptPlaceholder
;	call printStr
;	ld a, ' '
;	rst putc
	ld hl, promptStr
	call printStr
;	ld a, '>'
;	rst putc
;	ld a, ':'
;	rst putc
;	ld a, ' '
;	rst putc
	;call exit


	ld hl, inputBuffer
	ld c, 0
handleChar:
	;TODO navigation with arrow keys
	xor a
	rst getc
	cp 08h
	jr z, backspace
	cp 0dh
	jr z, handleLine
	;Check if printable
	cp 20h
	jr c, handleChar
	cp 7fh
	jr nc, handleChar
	ld (hl), a
	rst putc
	;Check for buffer overflow
	inc c
	ld a, c
	cp inputBufferSize
	jr nc, inputBufferOverflow
	inc hl
	jr handleChar

backspace:
	ld a, c
	cp 0
	jr z, handleChar
	ld a, 08h
	rst putc
	ld a, 20h
	rst putc
	ld a, 08h
	rst putc
	dec hl
	dec c
	jr handleChar

inputBufferOverflow:
	ld hl, inputBufferOverflowStr
	call printStr
	ret

inputBufferOverflowStr:
	.db "\r\nThe entered command is too long\r\n"
	.db 00h

handleLine:
	ld a, 0dh
	rst putc
	ld a, 0ah
	rst putc
	;TODO store history in file

	ld (hl), 00h
	ld hl, inputBuffer
	ld de, argv
	ld a, 00h
	ld (argc), a

	;break the input into individual strings
	ld a, (hl)
	cp 00h
	jr z, commandDispatch;finished the input string
	cp ' '
	jr z, nextArgSpace
	call addArg
	inc hl

nextArg:
	ld a, (hl)
	cp 00h
	jr z, commandDispatch;finished the input string
	cp ' '
	jr z, nextArgSpace
	inc hl
	jr nextArg

nextArgSpace:
	ld a, 00h
	ld (hl), a
	inc hl
	ld a, (hl)
	cp ' '
	jr z, nextArgSpace
	call addArg
	jr nextArg

addArg:
	;increment argc
	ld a, (argc)
	inc a
	cp maxArgc + 1
	jr nc, argOverflow;too many arguments
	ld (argc), a

	ld a, l
	ld (de), a
	inc de
	ld a, h
	ld (de), a
	inc de
	ret

argOverflow:
	ld hl, argOverflowStr
	call printStr
	pop hl
	jp prompt

argOverflowStr:
	.db "\r\nToo many arguments\r\n"
	.db 00h

commandDispatch:
	ld a, (argc)
	cp 00h
	jp z, prompt
	ld b, a
	ld de, argv

	;convert first command to uppercase
	ld a, (de)
	ld l, a
	inc de
	ld a, (de)
	ld h, a
	push hl
	call convertToUpper
	dec de

	;test: print out all arguments
;argLoop:
;	ld a, (de)
;	ld l, a
;	inc de
;	ld a, (de)
;	ld h, a
;	inc de
;	call printStr
;	ld a, 0dh
;	rst putc
;	ld a, 0ah
;	rst putc
;	djnz argLoop

	pop hl ;contains pointer to first string
	push hl

checkIfFullpath:
	;check if there is a / in the filename
	ld a, (hl)
	inc hl

	cp '/'
	jr z, fullPath

	cp 00h
	jr nz, checkIfFullpath

	ld bc, dispatchTable
	pop hl ;contains pointer to first string

dispatchLoop:
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
	jr z, programInPath
	push bc
	push hl
	call strCompare
	pop hl
	pop bc
	jr nz, dispatchLoop;no match

	;match, jump to builtin function
	dec bc
	ld a, (bc)
	ld h, a
	dec bc
	ld a, (bc)
	ld l, a
	ld de, prompt
	push de
	jp (hl)


programInPath:
	;check path for programs
	ld de, programName
	call strCopy

	ld de, programPath
	ld c, openFile
	call bcosVect
	cp 0
	jr z, loadProgram

	;TODO check default file extension


	jr noMatch


fullPath:
	;try to open file named &argv[0]
	pop de ;contains pointer to first string
	ld c, openFile
	call bcosVect
	cp 0
	jr nz, noMatch

loadProgram:
	;load file into memory
	ld a, e ;file descriptor
	push af
	ld de, 0c000h
	ld hl, 4000h
	ld c, readFile
	call bcosVect
	cp 0
	pop af
	jr nz, noMatch

	ld c, closeFile
	call bcosVect

	;TODO pass argc and argv

	ld de, prompt
	push de
	jp 0c000h

noMatch:
	ld hl, noMatchStr
	call printStr
	jp prompt

noMatchStr:
	.db "Command not recognised\r\n"
	.db 00h


argc:
	.db 0
argv:
	.resb maxArgc*2

promptStr:
	.db " >: \0"

;promptPlaceholder:
;	.db "/"
;	.db 00h

inputBuffer:
	.resb inputBufferSize


programPath:
	.db "/BIN/"
programName:
	.resb 13
programExtension:
	.db ".Z80\0"

;Command strings
echoStr:    .db "ECHO\0"
exitStr:    .db "EXIT\0"
monStr:     .db "MONITOR\0"
nullStr:    .db "\0"

dispatchTable:
	.dw echoStr, echo
	.dw exitStr, exit
	.dw monStr, cliMonitor
	.dw nullStr


;****************
;String Compare
;Description: Compares two strings
;Inputs: de, hl: String pointers
;Outputs: z if equal strings
;Destroyed: a, b
strCompare:
	ld a, (de)
	ld b, a
	ld a, (hl)
	cp b
	ret nz
	cp 00h
	ret z
	inc de
	inc hl
	jr strCompare


;****************
;String Copy
;Description: Copies a string from one location to another
;Inputs: hl: origin, de: destination
;Outputs: de, hl: point to the null terminators
;Destroyed: a
strCopy:
	ld a, (hl)
	ld (de), a
	cp 00h
	ret z
	inc hl
	inc de
	jr strCopy

;*****************
;ConvertToUpper
;Description: Converts a string to uppercase
;Inputs: hl: String pointer
;Outputs:
;Destroyed: none
convertToUpper:
	ld a, (hl)
	cp 0
	ret z

	cp 61h
	jr c, convertToUpper00
	cp 7bh
	jr nc, convertToUpper00
	sub 20h
	ld (hl), a
convertToUpper00:
	inc hl
	jr convertToUpper


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
	rst putc
	inc hl
	jr printStr


.include "builtins.asm"
