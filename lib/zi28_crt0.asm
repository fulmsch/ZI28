;       Startup Code for Embedded Targets
;
;	Daniel Wallner March 2002
;
;	$Id: embedded_crt0.asm,v 1.19 2016/07/13 22:12:25 dom Exp $
;
; (DM) Could this do with a cleanup to ensure rstXX functions are
; available?

	MODULE  zi28_crt0

;-------
; Include zcc_opt.def to find out information about us
;-------

        defc    crt0 = 1
	INCLUDE "zcc_opt.def"

;-------
; Some general scope declarations
;-------

        EXTERN    _main           ;main() is always external to crt0 code
        PUBLIC    cleanup         ;jp'd to by exit()
        PUBLIC    l_dcal          ;jp(hl)

	INCLUDE "os.h"


	org     MEM_user

	jp      start
start:
	;hl = **argv
	;bc = argc
	ex      de, hl ;de = **argv


; Make room for the atexit() stack
	ld      hl, -64
	add     hl, sp
	ld      sp, hl
	ld      (exitsp), sp

	push    bc ;argc
	push    de ;argv

; Clear static memory
	call    crt0_init_bss

; Initialise heap
	EXTERN  _mallinit
	call    _mallinit


; Entry to the user code
	call    _main
	pop     bc ;kill argv
	pop     bc ;kill argc

cleanup:
;
;       Deallocate memory which has been allocated here!
;
;IF !DEFINED_nostreams
;	EXTERN	closeall
;	call	closeall
;ENDIF

; Return to caller
	ld c, SYS_exit
	rst RST_syscall

l_dcal:
	jp      (hl)


        INCLUDE "crt0_runtime_selection.asm"

;	defc	__crt_org_bss = MEM_user
        ; If we were given a model then use it
        IF DEFINED_CRT_MODEL
            defc __crt_model = CRT_MODEL
        ELSE
            defc __crt_model = 1
        ENDIF
	INCLUDE	"crt0_section.asm"
