;;
.list
.z80

syscallTable:
	.dw u_open
	.dw u_close
	.dw u_read
	.dw u_write
	.dw u_seek
	.dw u_lseek
	.dw u_stat
	.dw u_fstat
	.dw u_readdir
	.dw u_dup
	.dw u_mount
	.dw u_unmount
	.dw u_unlink

syscallTableEnd:

.define nSyscalls 0+((syscallTableEnd - syscallTable)/2)


.func _syscall:
;; Access a system function from a running program.
;;
;; Input:
;; : c - Syscall number (defined in sys/os.h)
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
	pop af
	ld a, 0xff
	ret
.endf
