#code ROM

kalloc:
;; Allocates memory on the kernel heap. This memory cannot be freed.
;;
;; Input:
;; : hl - number of bytes to be allocated
;;
;; Output:
;; : hl - pointer to the allocated memory
;; : a - errno
;;
;; Errors:
;; : EINVAL - Zero bytes were requested
;; : ENOMEM - Kernel heap is out of memory

#local

;check that hl is not 0
	xor a
	cp h
	jr nz, notZero
	cp l
	jr nz, notZero

	ld a, EINVAL
	ret

notZero:
	; if (MEM_user - *kalloc_nextBlock < size) return ENOMEM;
	push hl ;size
	ld hl, MEM_user
	ld de, (kalloc_nextBlock)
	or a
	sbc hl, de
	; hl = maximum size
	pop de

	or a
	sbc hl, de
	jr c, memError

	; de = size
	ld hl, (kalloc_nextBlock)
	push hl
	; carry is not set
	adc hl, de
	ld (kalloc_nextBlock), hl
	pop hl
	ret


memError:
	ld a, ENOMEM
	ret
#endlocal

#data RAM
kalloc_nextBlock:
	DEFW 0
