;; Command line interface of the OS
;TODO change putc and getc to OS equivalents


.list
;.define inputBufferSize 128
;.define maxArgc 32


.func cli:

prompt:
	ld hl, promptStartStr
	call printStr

	ld hl, pathBuffer
	push hl
	call k_getcwd
	pop hl
	call printStr

	ld hl, promptEndStr
	call printStr


	ld hl, inputBuffer
	ld c, 0
handleChar:
	;TODO navigation with arrow keys
	xor a
	call getc
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
	call putc
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
	call putc
	ld a, 20h
	call putc
	ld a, 08h
	call putc
	dec hl
	dec c
	jr handleChar

inputBufferOverflow:
	ld hl, inputBufferOverflowStr
	call printStr
	ret

inputBufferOverflowStr:
	.asciiz "\nThe entered command is too long\n"

handleLine:
//	ld a, 0dh
//	call putc
	ld a, 0ah
	call putc
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
	.asciiz "\nToo many arguments\n"

commandDispatch:
	;terminate argv
	xor a
	ld (de), a
	inc de
	ld (de), a

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
;	call putc
;	ld a, 0ah
;	call putc
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
	;check path for programs
	;(hl) = command
	push hl

	ld hl, execPath
	ld de, cli_programName
	call strcpy

	pop hl
	;de points to null terminator
	call strcpy

	;TODO optimize
	ld de, cli_programName
	push de ;gets popped at fullPath

fullPath:
	;try to open file named &argv[0]
	pop de ;contains pointer to first string

	call exec
	cp 0
	jp z, prompt

noMatch:
	ld hl, noMatchStr
	call printStr
	jp prompt

noMatchStr:
	.asciiz "Command not recognised\n"

promptStartStr:
	.asciiz "["
promptEndStr:
	.asciiz "]$ "
.endf ;cli



execPath:
	.asciiz ":/BIN/"

;Command strings
chdirStr:   .asciiz "CD"
chmainStr:  .asciiz "CHMAIN"
clsStr:     .asciiz "CLS"
echoStr:    .asciiz "ECHO"
helpStr:    .asciiz "HELP"
monStr:     .asciiz "MONITOR"
mountStr:   .asciiz "MOUNT"
pwdStr:     .asciiz "PWD"
nullStr:    .db 00h

dispatchTable:
	.dw chdirStr,  b_chdir
	.dw chmainStr, b_chmain
	.dw clsStr,    b_cls
	.dw echoStr,   b_echo
	.dw helpStr,   b_help
	.dw monStr,    b_monitor
	.dw mountStr,  b_mount
	.dw pwdStr,    b_pwd
	.dw nullStr

.include "builtins/chdir.asm"
.include "builtins/chmain.asm"
.include "builtins/cls.asm"
.include "builtins/echo.asm"
.include "builtins/help.asm"
.include "builtins/monitor.asm"
.include "builtins/mount.asm"
.include "builtins/pwd.asm"
