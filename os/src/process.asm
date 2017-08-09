;;
.list


.func exec:
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

	;open file
	;(de) = filename
	ld a, 1 << O_RDONLY
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

	;set new stack
	ld sp, 0xc000


	call exec_addr

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

.endf
