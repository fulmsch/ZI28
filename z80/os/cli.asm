;TODO change putc and getc to OS equivalents


.list
;.define inputBufferSize 128
;.define maxArgc 32


.func cli:

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
	call strtup
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
;	;check if there is a / in the filename
;	ld a, (hl)
;	inc hl
;
;	cp '/'
;	jr z, fullPath
;
;	cp 00h
;	jr nz, checkIfFullpath

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
	call strcmp
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
;	;check path for programs
;	ld de, cliProgramName
;	call strcpy

;	ld de, programPath
	ex de, hl
	call k_open
	cp 0
	jr z, loadProgram

	;TODO check default file extension


	jr noMatch


fullPath:
	;try to open file named &argv[0]
	pop de ;contains pointer to first string
	call k_open
	cp 0
	jr nz, noMatch

loadProgram:
	;load file into memory
	ld a, e ;file descriptor
	push af
	ld de, 0c000h
	ld hl, 4000h
	call k_read
	cp 0
	pop af
	jr nz, noMatch

	call k_close

	;TODO pass argc and argv

	ld de, reentry
	push de
	jp 0c000h

reentry:
	jp prompt

noMatch:
	ld hl, noMatchStr
	call printStr
	jp prompt

noMatchStr:
	.db "Command not recognised\r\n"
	.db 00h

promptStr:
	.db " >: "
	.db 00h

;promptPlaceholder:
;	.db "/"
;	.db 00h

;inputBuffer:
;	.resb inputBufferSize

.endf ;cli


;argc:
;	.db 0
;argv:
;	.resb maxArgc*2


programPath:
	.db "/BIN/"
	;TODO fix this, broken because of rom
;programName:
;	.resb 13
programExtension:
	.db ".Z80"
	.db 00h

;Command strings
echoStr:    .asciiz "ECHO"
helpStr:    .asciiz "HELP"
lsStr:      .asciiz "LS"
monStr:     .asciiz "MONITOR"
mountStr:   .asciiz "MOUNT"
nullStr:    .db 00h

dispatchTable:
	.dw echoStr,  b_echo
	.dw helpStr,  b_help
	.dw lsStr,    b_ls
	.dw monStr,   b_monitor
	.dw mountStr, b_mount
	.dw nullStr

.include "builtins/echo.asm"
.include "builtins/help.asm"
.include "builtins/ls.asm"
.include "builtins/monitor.asm"
.include "builtins/mount.asm"
