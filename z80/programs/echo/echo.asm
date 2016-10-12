waitForInput:
	in a, (01h)
	bit 1, a
	jr nz, waitForInput
	in a, (00h)
	out (00h), a
	jr waitForInput
