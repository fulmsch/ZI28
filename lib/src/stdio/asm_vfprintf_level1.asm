

		PUBLIC	asm_vfprintf_level1


		SECTION	code_clib

asm_vfprintf_level1:
		defc   printflevel = 1
		defc   handlelong = 1
		INCLUDE "stdio/asm_printf_core.asm"
