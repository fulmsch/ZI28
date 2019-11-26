;; Command line interface of the OS
;TODO change putc and getc to OS equivalents

#code ROM

#define inputBufferSize 128
#define maxArgc          32


cli:
#local
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
	cp 0x0a ;'\n'
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
findArg:
	ld a, (hl)
	cp 0x00
	jr z, commandDispatch ;finished the input string
	cp '"'
	jr z, quotedArg
	cp ' '
	jr nz, foundArg
	inc hl
	jr findArg


foundArg:
	call addArg

insideOfArgLoop:
	inc hl
	ld a, (hl)
	cp 0x00
	jr z, commandDispatch ;finished the input string
	cp ' '
	jr nz, insideOfArgLoop

	xor a
	ld (hl), a
	inc hl
	jr findArg


quotedArg:
	inc hl
	call addArg

insideOfQuotedArgLoop:
	inc hl
	ld a, (hl)
	cp 0x00
	jr z, commandDispatch ;finished the input string
	cp '"'
	jr nz, insideOfQuotedArgLoop

	xor a
	ld (hl), a
	inc hl
	jr findArg

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
	jr z, checkExtension

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
	push de ;gets popped at checkExtension

checkExtension:
	;check if the filename has an extension, else add '.EX8'
	pop hl ;contains pointer to first string
	push hl
	call strlen
	; hl points to the null terminator
	ld d, h
	ld e, l

	;check the last 3 characters or the string length
	ld a, 3
	cp b
	jr nc, checkExtensionLoop
	ld b, a
checkExtensionLoop:
	dec hl
	ld a, (hl)
	cp '.'
	jr z, fullPath
	cp '/'
	jr z, addExtension
	djnz checkExtensionLoop

addExtension:
	;de points to the null terminator
	ld hl, execExtension
	call strcpy

fullPath:
	;try to open file named &argv[0]
	pop de ;contains pointer to first string
	push de
	ld hl, execStat
	call k_stat
	pop de ;contains pointer to first string
	cp 0
	jr nz, noMatch

	ld hl, argv
	call k_execv
	cp 0
	jp z, prompt

	call _strerror
	call print
	ld a, 0x0a ;'\n'
	rst RST_putc
	jp prompt

noMatch:
	ld hl, noMatchString
	call print
	jp prompt

;TODO customisable prompt
promptStartStr:
	DEFM 0x1b, "[36m", 0x00
promptEndStr:
	DEFM 0x1b, "[m$ ", 0x00


noMatchString:
	DEFM "Command not found\n", 0x00

execPath:
	DEFM "/BIN/", 0x00
execExtension:
	DEFM ".EX8", 0x00

#endlocal
;Command strings
chdirStr:   DEFM "CD", 0x00
clsStr:     DEFM "CLS", 0x00
echoStr:    DEFM "ECHO", 0x00
exitStr:    DEFM "EXIT", 0x00
;; forthStr:   DEFM "FORTH", 0x00
helpStr:    DEFM "HELP", 0x00
monStr:     DEFM "MONITOR", 0x00
mountStr:   DEFM "MOUNT", 0x00
pwdStr:     DEFM "PWD", 0x00
testStr:    DEFM "TEST", 0x00
verStr:     DEFM "VER", 0x00
nullStr:    DEFM 0x00

dispatchTable:
	;; Needs to be global for the 'help' builtin
	DEFW chdirStr,  b_chdir
	DEFW clsStr,    b_cls
	DEFW echoStr,   b_echo
	DEFW exitStr,   b_exit
	;; DEFW forthStr,  b_forth
	DEFW helpStr,   b_help
	DEFW monStr,    b_monitor
	DEFW mountStr,  b_mount
	DEFW pwdStr,    b_pwd
	DEFW testStr,   b_test
	DEFW verStr,    b_ver
	DEFW nullStr

#data RAM
argc: defb 0
argv: defs maxArgc * 2
inputBuffer: defs inputBufferSize

pathBuffer: defs PATH_MAX

env_workingPath: defs PATH_MAX

cli_programName: defs PATH_MAX
execStat:        defs STAT_LEN


#include "builtins/chdir.asm"
#include "builtins/cls.asm"
#include "builtins/echo.asm"
#include "builtins/exit.asm"
;; #include "forth.asm"
#include "builtins/help.asm"
#include "builtins/monitor.asm"
#include "builtins/mount.asm"
#include "builtins/pwd.asm"
#include "builtins/test.asm"
#include "builtins/ver.asm"
