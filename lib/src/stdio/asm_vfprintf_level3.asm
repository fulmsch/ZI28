

		PUBLIC	asm_vfprintf_level3


		SECTION	code_clib

asm_vfprintf_level3:
		defc   printflevel = 3
		defc   handlelong = 1
		INCLUDE "stdio/asm_printf_core.asm"
