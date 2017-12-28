; Memory map and section setup
;
; Contains the generic variables + features

; Generate a binary containing the code and data sections.
; The bss section gets initialised to 0 by the crt.

		SECTION CODE
		SECTION code_crt_init
crt0_init_bss:
	; Clear bss area
		EXTERN  __BSS_head
		EXTERN  __BSS_END_tail
		ld      hl,__BSS_head
		ld      de,__BSS_head + 1
		ld      bc,__BSS_END_tail - __BSS_head - 1
		xor     a
		ld      (hl),a
		ldir
IF !DEFINED_nostreams
	; Setup std* streams
		ld      hl,__sgoioblk
		ld      de,__sgoioblk+1
		ld      bc,59
		ld      (hl),0
		ldir
		ld      hl,__sgoioblk+0
		ld      (hl),0  ;STDIN_FILENO
		ld      hl,__sgoioblk+2
		ld      (hl),3 ;stdin  _IOUSE | _IOREAD
		ld      hl,__sgoioblk+6
		ld      (hl),1  ;STDOUT_FILENO
		ld      hl,__sgoioblk+8
		ld      (hl),5 ;stdout _IOUSE | _IOWRITE
		ld      hl,__sgoioblk+12
		ld      (hl),2  ;STDERR_FILENO
		ld      hl,__sgoioblk+14
		ld      (hl),5 ;stderr _IOUSE | _IOWRITE
ENDIF
IF DEFINED_USING_amalloc
    EXTERN __tail
	ld	hl,__tail
	ld	(_heap),hl
ENDIF
	
	; SDCC initialiation code gets placed here
		SECTION code_crt_exit

	ret
		SECTION code_compiler
		SECTION code_clib
		SECTION code_crt0_sccz80
		SECTION code_l_sdcc
		SECTION code_l
		SECTION code_compress_zx7
		SECTION code_fp
		SECTION code_fp_math48
		SECTION code_math
		SECTION code_error
		SECTION code_user
		SECTION rodata_fp
		SECTION rodata_compiler
		SECTION rodata_clib
		SECTION rodata_user
		SECTION ROMABLE_END
		SECTION DATA
		SECTION smc_clib
		SECTION data_crt
		PUBLIC  exitsp
exitsp:          defw    0       ;atexit() stack
		SECTION data_compiler
		SECTION data_user
		SECTION DATA_END

		SECTION BSS
			org -1
			defb 0
		SECTION bss_fp
		SECTION bss_error
		SECTION bss_crt
		PUBLIC  _errno
_errno:         defw 0
IF !DEFINED_nostreams
		PUBLIC  __sgoioblk
__sgoioblk:      defs    60      ;stdio control block
ENDIF
		PUBLIC  base_graphics
		PUBLIC  exitcount
IF !DEFINED_basegraphics
base_graphics:   defw    0       ;Address of graphics map
ENDIF
exitcount:       defb    0       ;Number of atexit() routines
IF DEFINED_USING_amalloc
		PUBLIC _heap
; The heap pointer will be wiped at startup,
; but first its value (based on __tail)
; will be kept for sbrk() to setup the malloc area
_heap:
		defw 0          ; Initialised by code_crt_init - location of the last program byte
		defw 0
ENDIF
		SECTION bss_fardata
IF __crt_org_bss_fardata_start
		org	__crt_org_bss_fardata_start
ENDIF
		SECTION bss_compiler
IF __crt_org_bss_compiler_start
		org	__crt_org_bss_compiler_start
ENDIF
		SECTION bss_clib
		SECTION bss_user
		SECTION BSS_END
