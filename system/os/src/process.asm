SECTION rom_code
INCLUDE "os.h"
INCLUDE "string.h"
INCLUDE "os_memmap.h"

PUBLIC exec

EXTERN k_open, k_read, k_close, udup, u_close, bankOs, bankSwitch

exec:
;; Loads a program file into memory and executes it.
;;
;; The file descriptors for input and output must be set before calling exec.
;; All open file descriptors will be closed when the process is terminated.
;;
;; Input:
;; : (de) - filename
;; : (hl) - argv
;;
;; Output:
;; : a - errno
;; : hl - return code

	push de
	push hl

	;advance de to end of filename
extLoop3:
	ld a, (de)
	inc de
	cp 0x00
	jr nz, extLoop3

	dec de
	;de points to null terminator

	;check whether a file extension has been specified
	ld b, 4
extLoop0:
	dec de
	ld a, (de)
	cp '.'
	jr z, openFile
	cp '/'
	jr z, extLoop1
	djnz extLoop0

	;no extension, add default executable one
extLoop1:
	inc de
	ld a, (de)
	cp 0x00
	jr nz, extLoop1

	ld hl, execExtension
	call strcpy

openFile:
	pop hl
	pop de

	;open file
	;(de) = filename
	ld a, O_RDONLY
	call k_open
	cp 0
	ret nz ;error opening the file
	ld a, e
	ld (exec_fd), a

	;TODO check magic number (binary/interpreted)
	
	;load file into memory
	ld a, (exec_fd)
	ld de, exec_addr
	ld hl, 4000h
	call k_read ;TODO error checking

	;close file
	ld a, (exec_fd)
	call k_close

	;TODO setup for execution (argv, signals, interrupts, etc.)

	;set up standard streams
	ld a, STDIN_FILENO
	ld b, a
	call udup ;STDIN

	ld a, STDOUT_FILENO
	ld b, a
	call udup ;STDOUT

	ld a, STDERR_FILENO
	ld b, a
	call udup ;STDERR

	;save the stack pointer
	ld (exec_stack), sp

	xor a
	call bankSwitch

	;set new stack
	ld sp, 0xa000

	;command line arguments TODO just temporary
	ld a, (argc)
	ld c, a
	ld b, 0
	ld hl, argv

	call exec_addr

	call bankOs

	;restore the stack pointer
	ld sp, (exec_stack)

	;close all files
	ld b, fdTableEntries
closeFilesLoop:
	ld a, b
	dec a
	push bc
	call u_close
	pop bc
	djnz closeFilesLoop

	;clear the user fd-table just in case
	ld hl, u_fdTable
	ld de, u_fdTable + 1
	ld bc, fdTableEntries - 1
	ld (hl), 0xff
	ldir

	xor a
	ret


execExtension:
	DEFM ".EX8", 0x00
