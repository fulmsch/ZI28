#include "macros.asm"

; RESET AND INTERRUPT VECTORS ===================

	org 0x0000   ; Entry point

	di           ; RST 0x00
	jp RESET
	nop
	nop
	nop
	nop

	jp putc      ; RST 0x08
	nop
	nop
	nop
	nop
	nop

	jp getc      ; RST 0x10
	nop
	nop
	nop
	nop
	nop

	jp CKINCHAR  ; RST 0x18
	nop
	nop
	nop
	nop
	nop

RST_next:        ; RST 0x20
	pop hl ; discard return address
	ex de, hl
	ld e, (hl)
	inc hl
	ld d, (hl)
	inc hl
	ex de, hl
	jp (hl)

	nop         ; RST 0x28
	nop
	nop
	nop
	nop
	nop
	nop
	nop

	nop         ; RST 0x30
	nop
	nop
	nop
	nop
	nop
	nop
	nop

	nop         ; RST 0x38

;------------------------------------------------------------------------------

FT240_DATA_PORT   = 0
FT240_STATUS_PORT = 1

getc:
_getc_blocking:
	in a, (FT240_STATUS_PORT)
	bit 1, a
	jr nz, _getc_blocking
	in a, (FT240_DATA_PORT)
	cp 0x0d ;'\r'
	jr z, _getc_blocking
	ret

putc:
	push af
_putc_poll:
	in a, (FT240_STATUS_PORT)
	bit 0, a
	jr nz, _putc_poll
	pop af
	cp 0x0a ;'\n'
	call z, _putc_newline
	out (FT240_DATA_PORT), a
	ret
_putc_newline:
	ld a, 0x0d ;'\r'
	out (FT240_DATA_PORT), a
	ld a, 0x0a ;'\n'
	ret

CKINCHAR:
	in a, (FT240_STATUS_PORT)
	bit 1, a
	ret

;------------------------------------------------------------------------------

RAMEND = 0xFFFF
RESET:  ld hl,RAMEND
	ld l,0       ;    = end of avail.mem (EM)
	dec h        ; EM-0x100
	ld sp,hl     ;      = top of param stack
	inc h        ; EM
	push hl
	pop ix       ;      = top of return stack
	dec h        ; EM-0x200
	dec h
	push hl
	pop iy       ;      = bottom of user area
	ld de,1      ; do reset if COLD returns
	jp COLD      ; enter top-level Forth word

; Memory map:
;   0-0x2000    Forth kernel = start of 
;     ? h       Forth dictionary (user RAM)
;   EM-0x280    Terminal Input Buffer, 128 bytes
;   EM-0x200    User area, 128 bytes
;   EM-0x180    Parameter stack, 128B, grows down
;   EM-0x100    HOLD area, 40 bytes, grows down
;   EM-0x0D8    PAD buffer, 88 bytes
;   EM-80h      Return stack, 128 B, grows down
;   EM          End of RAM = changes based on 32k vs 64k
; See also the definitions of U0, S0, and R0
; in the "system variables & constants" area.
; A task w/o terminal input requires 0x200 bytes.
; Double all except TIB and PAD for 32-bit CPUs.

#include "forthdict.asm"
