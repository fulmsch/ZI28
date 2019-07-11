;TODO: update documentation
; ===============================================
; Macros to define Forth headers
; HEAD  label,length,name,action
; IMMED label,length,name,action
;    label  = assembler name for this word
;             (special characters not allowed)
;    length = length of name field
;    name   = Forth's name for this word
;    action = code routine for this  word, e.g.
;             DOCOLON, or DOCODE for code words
; IMMED defines a header for an IMMEDIATE word.
;

link    defl 0 ; link to previous Forth word
F_IMMED equ  1 ; immediate word flag


defcode macro   #label,#length,#name,#flags
	dw link
	db #flags
link    defl $
	db #length,'#name'
#label:
	endm


defword macro   #label,#length,#name,#flags
	dw link
	db #flags
link    defl $
	db #length,'#name'
#label:
	call docolon
	endm


defconst macro   #label,#length,#name,#flags,#value
	dw link
	db #flags
link    defl $
	db #length,'#name'
#label:
	call docon
	dw #value
	endm


; TODO offset is relative, maybe change this?
defvar macro   #label,#length,#name,#flags,#offset
	dw link
	db #flags
link    defl $
	db #length,'#name'
#label:
	call douser
	dw #offset
	endm


; The NEXT macro (7 bytes) assembles the 'next'
; code in-line in every Z80 CamelForth CODE word.
next    macro
	rst RST_next
	endm


; NEXTHL is used when the IP is already in HL.
nexthl  macro
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ex de,hl
	jp (hl)
	endm
