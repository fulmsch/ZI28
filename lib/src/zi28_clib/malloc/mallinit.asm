; void mallinit(void)
; 12.2006 aralbrec

SECTION code_clib
PUBLIC mallinit
PUBLIC _mallinit

EXTERN _heap

.mallinit
._mallinit

	ld hl, mallinit_heap_start
	ld de, _heap
	ld bc, 8
	ldir
	ret

SECTION rodata_clib
.mallinit_heap_start
	defb 0x00, 0x00, 0x04, 0xc0, 0xfa, 0x3f, 0x00, 0x00
;        \  size  /  \  next  /  \  size  /  \  next  /
