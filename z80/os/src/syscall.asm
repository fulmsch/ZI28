;;
.list
.z80

syscallTable:
	.dw k_open
	.dw k_close
	.dw k_read
	.dw k_write
	.dw k_seek
	.dw k_lseek
	.dw k_stat
	.dw k_fstat
	.dw k_readdir
	.dw k_dup
	.dw k_mount
	.dw k_chmain

syscallTableEnd:

.define nSyscalls 0+((syscallTableEnd - syscallTable)/2)


.func _syscall:
;; Access a system function from a running program.
;;
;; Input:
;; : c - Syscall number (defined in syscall.h)
;; : a, de, hl - Arguments passed to syscall

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
	ld a, 0xff
	ret
.endf
