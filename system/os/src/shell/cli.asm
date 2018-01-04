SECTION rom_code
;; Command line interface of the OS
;TODO change putc and getc to OS equivalents


INCLUDE "os.h"
INCLUDE "string.h"

EXTERN k_getcwd, exec

DEFC inputBufferSize         = 128
DEFC maxArgc                 = 32


PUBLIC cli
cli:
prompt:
	ld hl, promptStartStr
	call print

	ld hl, pathBuffer
	push hl
	call k_getcwd
	pop hl
	call print

	ld hl, promptEndStr
	call print


	ld hl, inputBuffer
	ld c, 0
handleChar:
	;TODO navigation with arrow keys
	xor a
	rst RST_getc
	cp 0x08
	jr z, backspace
	cp '\n'
	jr z, handleLine
	;Check if printable
	cp 0x20
	jr c, handleChar
	cp 0x7f
	jr nc, handleChar
	ld (hl), a
	rst RST_putc
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
	ld a, 0x08
	rst RST_putc
	ld a, 0x20
	rst RST_putc
	ld a, 0x08
	rst RST_putc
	dec hl
	dec c
	jr handleChar

inputBufferOverflow:
	ld hl, inputBufferOverflowStr
	call print
	jr prompt

inputBufferOverflowStr:
	DEFM "\nThe entered command is too long\n", 0x00

handleLine:
;	ld a, 0x0d
;	rst RST_putc
	ld a, 0x0a
	rst RST_putc
	;TODO store history in file

	ld (hl), 0x00
	ld hl, inputBuffer
	ld de, argv
	ld a, 0x00
	ld (argc), a

	;break the input into individual strings
	ld a, (hl)
	cp 0x00
	jr z, commandDispatch;finished the input string
	cp ' '
	jr z, nextArgSpace
	call addArg
	inc hl

nextArg:
	ld a, (hl)
	cp 0x00
	jr z, commandDispatch;finished the input string
	cp ' '
	jr z, nextArgSpace
	inc hl
	jr nextArg

nextArgSpace:
	ld a, 0x00
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
	call print
	pop hl
	jp prompt

argOverflowStr:
	DEFM "\nToo many arguments\n", 0x00

commandDispatch:
	;terminate argv
	xor a
	ld (de), a
	inc de
	ld (de), a

	ld a, (argc)
	cp 0x00
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
;	call print
;	ld a, 0x0d
;	rst RST_putc
;	ld a, 0x0a
;	rst RST_putc
;	djnz argLoop

	pop hl ;contains pointer to first string
	push hl

checkIfFullpath:
	;check if there is a / in the filename
	ld a, (hl)
	inc hl

	cp '/'
	jr z, fullPath

	cp 0x00
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
	cp 0x00
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
	call print
	jp prompt

noMatchStr:
	DEFM "Command not recognised\n", 0x00

;TODO customisable prompt
promptStartStr:
	DEFM 0x1b, "[36m", 0x00
promptEndStr:
	DEFM 0x1b, "[m$ ", 0x00



execPath:
	DEFM "/BIN/", 0x00

;Command strings
chdirStr:   DEFM "CD", 0x00
clsStr:     DEFM "CLS", 0x00
echoStr:    DEFM "ECHO", 0x00
helpStr:    DEFM "HELP", 0x00
monStr:     DEFM "MONITOR", 0x00
mountStr:   DEFM "MOUNT", 0x00
pwdStr:     DEFM "PWD", 0x00
testStr:    DEFM "TEST", 0x00
verStr:     DEFM "VER", 0x00
nullStr:    DEFM 0x00

PUBLIC dispatchTable
EXTERN b_chdir, b_cls, b_echo, b_help, b_monitor, b_mount, b_pwd, b_test, b_ver
dispatchTable:
	DEFW chdirStr,  b_chdir
	DEFW clsStr,    b_cls
	DEFW echoStr,   b_echo
	DEFW helpStr,   b_help
	DEFW monStr,    b_monitor
	DEFW mountStr,  b_mount
	DEFW pwdStr,    b_pwd
	DEFW testStr,   b_test
	DEFW verStr,    b_ver
	DEFW nullStr

SECTION CRAM
PUBLIC argc, argv, inputBuffer
argc: defb 0
argv: defs maxArgc * 2
inputBuffer: defs inputBufferSize

SECTION bram_os

PUBLIC pathBuffer
pathBuffer: defs PATH_MAX

PUBLIC env_workingPath
env_workingPath: defs PATH_MAX

cli_programName: defs 13
