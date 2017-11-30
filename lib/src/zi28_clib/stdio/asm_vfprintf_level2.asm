

		PUBLIC	asm_vfprintf_level2


		SECTION	code_clib

asm_vfprintf_level2:
		defc   printflevel = 2
		defc   handlelong = 1
		INCLUDE "asm_printf_core.asm"
