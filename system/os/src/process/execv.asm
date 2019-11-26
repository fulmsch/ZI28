#code ROM

u_execv:
;; Execute a program.
;;
;; Input:
;; : (de) - path
;; : (hl) - argv
;;
;; Output:
;; : a - errno
;;
;; Errors:
;; : E2BIG - The argument list (argv) is too big.
;; : EACCES, EIO, ENFILE, ENAMETOOLONG, ENOENT, ENOTDIR

k_execv:

#local
	ld (execv_argv), hl
	ld (execv_path), de

	;set up standard streams TODO temporary
	ld a, STDIN_FILENO
	ld b, a
	call udup ;STDIN

	ld a, STDOUT_FILENO
	ld b, a
	call udup ;STDOUT

	ld a, STDERR_FILENO
	ld b, a
	call udup ;STDERR


	;copy each argument
	ld h, 0 ;count
	push hl
	ld hl, (execv_argv) ;count on stack, vector in hl
	ld de, execv_args

copyArguments:
	ld c, (hl)
	inc hl
	ld b, (hl)
	inc hl
	ex (sp), hl ;count in hl, vector on stack

	;(bc) = argument
	;check if null
	xor a
	cp c
	jr nz, copyArg
	cp b
	jr z, copyArgumentsEnd

copyArg:
;; Input:
;; : (bc) - source
;; : (de) - destination
	ld a, process_max_args_length
	inc h
	cp h
	jr z, argLengthError ;argument string too long
	ld a, (bc)
	ld (de), a
	cp 0x00
	inc bc
	inc de
	jr nz, copyArg

	ex (sp), hl ;count on stack, vector in hl
	jr copyArguments


copyArgumentsEnd:
	pop hl ;clear stack
	xor a
	ld (de), a ;terminate argument string

;count arguments
	ld hl, execv_args
	ld d, a ;0
	cp (hl)
	jr z, countArgumentsEnd

countArguments:
	inc d
	call strlen
	inc hl
	cp (hl) ;a is 0 after strlen
	jr nz, countArguments

countArgumentsEnd:
	;d = argc
	ld a, d
	cp process_max_argc + 1
	jr nc, argCountError
	ld (execv_argc), a




	;open file
	ld de, (execv_path)
	ld a, O_RDONLY
	call k_open
	cp 0
	ret nz ;error opening the file
	ld a, e

	;TODO check not dir
	;TODO check magic number (binary/interpreted)
	
	push af
	;load file into memory
	ld de, MEM_user
	ld hl, MEM_user_top - MEM_user
	call k_read ;TODO error checking

	;close file
	pop af
	call k_close



	;copy argument string to program data section
	ld hl, execv_args
	ld de, process_argString
	ld bc, process_max_args_length
	ldir

	;build argv
	ld de, process_argVector
	ld hl, process_argString
	xor a

generateArgv:
	cp (hl)
	jr z, argvEnd
	ld a, l
	ld (de), a
	inc de
	ld a, h
	ld (de), a
	inc de
	call strlen
	inc hl
	jr generateArgv

argvEnd:
	;terminate argv
	ld (de), a
	inc de
	ld (de), a


	ld (kernel_stackSave), sp
	ld sp, MEM_user_top
	;push addr of exit so that the program can terminate with a ret
	ld bc, u_exit
	push bc
	ld bc, (execv_argc)
	ld b, 0
	ld hl, process_argVector
	jp MEM_user


argLengthError:
	pop hl
argCountError:
	ld a, E2BIG
	ret
#endlocal

#data RAM
execv_path: defs 2
execv_argv: defs 2
execv_argc: defs 1
execv_args: defs process_max_args_length
