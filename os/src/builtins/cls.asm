.list

.func b_cls:
	ld hl, clearSequence
	jp printStr

clearSequence:
	.db 0x1b
	.ascii "[2J"
	.db 0x1b
	.asciiz "[H"
.endf
