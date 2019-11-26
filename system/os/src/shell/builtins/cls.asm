#code ROM

b_cls:
#local
	ld hl, clearSequence
	jp print

clearSequence:
	DEFM 0x1b, "[2J"
	DEFM 0x1b, "[H", 0x00
#endlocal
