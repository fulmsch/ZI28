SECTION rom_code
INCLUDE "os.h"
INCLUDE "process.h"

PUBLIC u_execv, k_execv

EXTERN k_open, k_read, k_close, udup
EXTERN kernel_stackSave

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

; set up process data area(fd table)
; copy argv
; jp 0x8000

	ld (execv_argv), hl
	;open file
	;(de) = filename
	ld a, O_RDONLY
	call k_open
	cp 0
	ret nz ;error opening the file
	ld a, e

	;TODO check not dir
	;TODO check magic number (binary/interpreted)
	
	push af
	;load file into memory
	ld de, ram_user
	ld hl, 0x4000
	call k_read ;TODO error checking

	;close file
	pop af
	call k_close

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


	;count arguments
	ld hl, (execv_argv)
	xor a
	ld b, a
	ld c, a
	dec hl

argCountLoop:
	inc bc
	inc hl
	cp (hl)
	inc hl
	jr nz, argCountLoop ;inc hl first
	cp (hl)
	jr nz, argCountLoop

	;hl points to second byte of null terminator
	ld de, process_argv_top - 1
	push bc
	;double bc
	sla c
	rl b

	lddr
	pop bc
	dec bc ;bc = argc
	ex de, hl ;hl = process argv
	inc hl

	;TODO copy args
	ld (kernel_stackSave), sp
	ld sp, process_argv_top
	;push addr of exit so that the program can terminate with a ret?
	jp ram_user

SECTION ram_os
execv_argv: defs 2
