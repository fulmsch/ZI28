#code ROM

	;; TODO make everything except _syscall local
#define nSyscalls ((syscallTableEnd - syscallTable) / 2)

syscallTable:
	DEFW u_open
	DEFW u_close
	DEFW u_read
	DEFW u_write
	DEFW u_seek
	DEFW u_lseek
	DEFW u_stat
	DEFW u_fstat
	DEFW u_readdir
	DEFW u_dup
	DEFW u_mount
	DEFW u_unmount
	DEFW u_unlink
	DEFW u_bsel
	DEFW u_execv
	DEFW u_exit
	DEFW u_chdir
	DEFW u_getcwd
syscallTableEnd:
	;; TODO can this be removed?
	DEFB 0

_syscall:
;; Access a system function from a running program.
;;
;; Input:
;; : c - Syscall number (defined in sys/os.h)
;; : a, de, hl - Arguments passed to syscall

#local
;check for valid syscall number
	push af
	ld a, nSyscalls
	cp c
	jr c, error
	pop af

;calculate the vector
	push hl
	sla c
	ld l, c
	ld h, syscallTable >> 8

;load the jump address into bc
	ld c, (hl)
	inc hl
	ld b, (hl)
	pop hl

;jump to bc
	push bc
	ret

error:
	pop af
	ld a, ENOSYS
	ret
#endlocal
