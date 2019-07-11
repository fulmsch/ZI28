SECTION rom_code
INCLUDE "os.h"
INCLUDE "string.h"
INCLUDE "cli.h"

PUBLIC b_forth

;   BC = TOS   IX = RSP
;   DE = IP    IY = UP
;   HL = W     SP = PSP

	DEFC F_IMMED   = 0x80
	DEFC F_HIDDEN  = 0x20
	DEFC F_LENMASK = 0x1f ; length mask


RST_next:
	pop hl     ;  1, 10 discard return address
JP_next:
	ld a, (de) ;  1,  7 (IP)->W, increment IP
	ld l, a    ;  1,  4
	inc de     ;  1,  6
	ld a, (de) ;  1,  7
	ld h, a    ;  1,  4
	inc de     ;  1,  6
	jp (hl)    ;  1,  4 jump to address in W
	; Total       8, 48

RST_docol:
	dec ix       ; 2, 10 push the old IP on the return stack
	ld (ix+0), d ; 3, 19
	dec ix       ; 2, 10
	ld (ix+0), e ; 3, 19
	pop hl       ; 1, 10 Parameter Field address -> HL
	ld e, (hl)   ; 1,  7 next_hl
	inc hl       ; 1,  6
	ld d, (hl)   ; 1,  7
	inc hl       ; 1,  6
	ex de, hl    ; 1,  4
	jp (hl)      ; 1,  4 jump to address in W
	; Total       17,102

b_forth:
	ld hl, 0
	ld (var_STATE), hl
	add hl, sp
	ld (var_SZ), hl

	ld hl, 10
	ld (var_BASE), hl

	ld hl, latestWord
	ld (var_LATEST), hl

	ld hl, 0xc000
	ld (var_HERE), hl


	ld ix, return_stack_top

	ld hl, 0
	push hl
	push hl
	push hl
	ld de, cold_start
	call RST_next


cold_start:
	DEFW QUIT


name_DROP:
	DEFW 0x0000
	DEFM 4, "DROP"
DROP:
	pop hl
	call RST_next


name_SWAP:
	DEFW name_DROP
	DEFM 4, "SWAP"
SWAP:
	pop hl
	ex (sp), hl
	push hl
	call RST_next


name_DUP:
	DEFW name_SWAP
	DEFM 3, "DUP"
DUP:
	pop hl
	push hl
	push hl
	call RST_next


name_OVER:
	DEFW name_DUP
	DEFM 4, "OVER"
OVER:
	inc sp
	inc sp
	pop hl
	push hl
	dec sp
	dec sp
	push hl
	call RST_next


name_ROT:
	DEFW name_OVER
	DEFM 3, "ROT"
ROT:
	pop bc
	pop hl
	ex (sp), hl
	push bc
	push hl
	call RST_next


name_NROT:
	DEFW name_ROT
	DEFM 4, "-ROT"
NROT:
	pop hl
	pop bc
	ex (sp), hl
	push hl
	push bc
	call RST_next


name_TWODROP:
	DEFW name_NROT
	DEFM 5, "2DROP"
TWODROP:
	pop hl
	pop hl
	call RST_next


name_TWODUP:
	DEFW name_TWODROP
	DEFM 4, "2DUP"
TWODUP:
	pop hl
	pop bc
	push bc
	push hl
	push bc
	push hl
	call RST_next


name_TWOSWAP:
	DEFW name_TWODUP
	DEFM 5, "2SWAP"
TWOSWAP:
	ld b, d
	ld c, e
	pop hl
	pop de
	ex (sp), hl
	inc sp
	inc sp
	ex de, hl
	ex (sp), hl
	dec sp
	dec sp
	push hl
	push de
	ld d, b
	ld e, c
	call RST_next


name_QDUP:
	DEFW name_TWOSWAP
	DEFM 4, "?DUP"
QDUP:
	pop hl
	push hl
	xor a
	ld b, a
	ld c, a
	sbc hl, bc
	jp JP_next
	push hl
	call RST_next


name_INCR:
	DEFW name_QDUP
	DEFM 2, "1+"
INCR:
	pop hl
	inc hl
	push hl
	call RST_next


name_DECR:
	DEFW name_INCR
	DEFM 2, "1-"
DECR:
	pop hl
	dec hl
	push hl
	call RST_next


name_INCR2:
	DEFW name_DECR
	DEFM 2, "2+"
INCR2:
	pop hl
	inc hl
	inc hl
	push hl
	call RST_next


name_DECR2:
	DEFW name_INCR2
	DEFM 2, "2-"
DECR2:
	pop hl
	dec hl
	dec hl
	push hl
	call RST_next


name_ABS:
	DEFW name_DECR2
	DEFM 3, "ABS"
ABS:
	pop bc
	xor a
	add a, b
	jp p, ABS1
	ld hl, 0
	sbc hl, bc
	push hl
	call RST_next

ABS1:
	push bc
	call RST_next



name_NEGATE:
	DEFW name_DECR2
	DEFM 6, "NEGATE"
NEGATE:
	pop bc
	ld hl, 0
	or a
	sbc hl, bc
	push bc
	call RST_next


; ?NEGATE  n1 n -- n2   negate n1 if n negative
name_QNEGATE:
	DEFW name_NEGATE
	DEFM 7, "?NEGATE"
QNEGATE:
	pop hl
	xor a
	add a, h
	jp p, JP_next
	jr NEGATE


name_ADD:
	DEFW name_QNEGATE
	DEFM 1, "+"
ADD:
	pop bc
	pop hl
	add hl, bc
	push hl
	call RST_next


name_SUB:
	DEFW name_ADD
	DEFM 1, "-"
SUB:
	pop bc
	pop hl
	or a
	sbc hl, bc
	push hl
	call RST_next


;C UM*     u1 u2 -- ud   unsigned 16x16->32 mult.
name_UMSTAR:
	DEFW name_SUB
	DEFM 3, "UM*"
UMSTAR:
	pop bc      ; u2 in BC
	pop hl
	push de     ; save de
	ex de, hl   ; u1 in DE
	ld hl, 0    ; result will be in HLDE
	ld a, 17    ; loop counter
	or a        ; clear cy
UMSTAR_loop:
	rr h
	rr l
	rr d
	rr e
	jr nc, UMSTAR_noadd
	add hl,bc
UMSTAR_noadd:
	dec a
	jr nz, UMSTAR_loop
	pop bc      ; IP
	push de     ; lo result
	push hl     ; hi result
	ld d, b
	ld e, c
	call RST_next


name_MUL:
	DEFW name_UMSTAR
	DEFM 1, "*"
MUL:
	call RST_docol
	DEFW TWODUP, XOR, TOR
	DEFW SWAP, ABS, SWAP, ABS, UMSTAR
	DEFW DROP, FROMR, QNEGATE, EXIT


;C UM/MOD   ud u1 -- u2 u3   unsigned 32/16->16
name_UMSLASHMOD:
	DEFW name_MUL
	DEFM 6, "UM/MOD"
UMSLASHMOD:
	pop bc      ; BC = divisor
	pop hl      ; HLDE = dividend
	ex de, hl
	ex (sp), hl
	ex de, hl
	ld a, 16    ; loop counter
	sla e
	rl d        ; hi bit DE -> carry
UMSLASHMOD_loop:
	adc hl, hl   ; rot left w/ carry
	jr nc, udiv3
	; case 1: 17 bit, cy:HL = 1xxxx
	or a        ; we know we can subtract
	sbc hl, bc
	or a        ; clear cy to indicate sub ok
	jr udiv4
	; case 2: 16 bit, cy:HL = 0xxxx
udiv3:
	sbc hl, bc   ; try the subtract
	jr nc, udiv4 ; if no cy, subtract ok
	add hl, bc   ; else cancel the subtract
	scf         ;   and set cy to indicate
udiv4:
	rl e        ; rotate result bit into DE,
	rl d        ; and next bit of DE into cy
	dec a
	jr nz, UMSLASHMOD_loop
	; now have complemented quotient in DE,
	; and remainder in HL
	ld a, d
	cpl
	ld b, a
	ld a, e
	cpl
	ld c, a
	pop de      ; restore IP
	push hl     ; push remainder
	push bc
	call RST_next


name_EQU:
	DEFW name_UMSLASHMOD
	DEFM 1, "="
EQU:
	pop bc
	pop hl
	or a
	sbc hl, bc ;z: push 1, nz: 0
	dec hl
	jr z, EQU1
	ld hl, 0
EQU1:
	push hl
	call RST_next


name_NEQU:
	DEFW name_EQU
	DEFM 2, "<>"
NEQU:
	pop bc
	pop hl
	or a
	sbc hl, bc ;z: push 0, nz: 1
	jr z, NEQU1
	ld hl, -1
NEQU1:
	push hl


name_LT:
	DEFW name_NEQU
	DEFM 1, "<"
LT:
	pop bc
	pop hl
	or a
	sbc hl, bc
	ld hl, 0
	jr nc, LT1
	dec hl
LT1:
	push hl
	call RST_next


name_GT:
	DEFW name_LT
	DEFM 1, ">"
GT:
	pop bc
	pop hl
	or a
	sbc hl, bc
	ld hl, 0
	jr c, GT1
	dec hl
GT1:
	push hl
	call RST_next


name_LE:
	DEFW name_GT
	DEFM 2, "<="
LE:
	pop hl
	pop bc
	or a
	sbc hl, bc
	ld hl, 0
	jr c, LE1
	jr nz, LE1
	dec hl
LE1:
	push hl
	call RST_next


name_GE:
	DEFW name_LE
	DEFM 2, ">="
GE:
	pop bc
	pop hl
	or a
	sbc hl, bc
	ld hl, 0
	jr c, GE1
	jr nz, GE1
	dec hl
GE1:
	push hl
	call RST_next


name_ZEQU:
	DEFW name_GE
	DEFM 2, "0="
ZEQU:
	ld bc, 0
	pop hl
	or a
	sbc hl, bc
	dec hl
	jr z, ZEQU1
	ld hl, 0
ZEQU1:
	push hl
	call RST_next


name_ZNEQU:
	DEFW name_ZEQU
	DEFM 3, "0<>"
ZNEQU:
	pop hl
	or a
	ld bc, 0
	sbc hl, bc
	jr z, ZNEQU1
	ld hl, -1
ZNEQU1:
	push hl
	call RST_next


name_ZLT:
	DEFW name_ZNEQU
	DEFM 1, "0<"
ZLT:
	ld bc, 0
	pop hl
	or a
	sbc hl, bc
	ld hl, 0
	jr nc, ZLT1
	dec hl
ZLT1:
	push hl
	call RST_next


name_ZGT:
	DEFW name_ZLT
	DEFM 1, "0>"
ZGT:
	ld bc, 0
	pop hl
	or a
	sbc hl, bc
	ld hl, 0
	jr c, ZGT1
	dec hl
ZGT1:
	push hl
	call RST_next


name_ZLE:
	DEFW name_ZGT
	DEFM 2, "0<="
ZLE:
	ld hl, 0
	pop bc
	or a
	sbc hl, bc
	ld hl, 0
	jr c, ZLE1
	jr nz, ZLE1
	dec hl
ZLE1:
	push hl
	call RST_next


name_ZGE:
	DEFW name_ZLE
	DEFM 2, "0>="
ZGE:
	ld bc, 0
	pop hl
	or a
	sbc hl, bc
	ld hl, 0
	jr c, ZGE1
	jr nz, ZGE1
	dec hl
ZGE1:
	push hl
	call RST_next


name_AND:
	DEFW name_ZGE
	DEFM 3, "AND"
AND:
	pop hl
	pop bc
	ld a, c
	and l
	ld l, a
	ld a, b
	and h
	ld h, a
	push hl
	call RST_next


name_OR:
	DEFW name_AND
	DEFM 2, "OR"
OR:
	pop hl
	pop bc
	ld a, c
	or l
	ld l, a
	ld a, b
	or h
	ld h, a
	push hl
	call RST_next


name_XOR:
	DEFW name_OR
	DEFM 3, "XOR"
XOR:
	pop hl
	pop bc
	ld a, c
	xor l
	ld l, a
	ld a, b
	xor h
	ld h, a
	push hl
	call RST_next


name_INVERT:
	DEFW name_XOR
	DEFM 6, "INVERT"
INVERT:
	pop hl
	ld a, h
	cpl
	ld h, a
	ld a, l
	cpl
	ld l, a
	push hl
	call RST_next


name_EXIT:
	DEFW name_INVERT
	DEFM 4, "EXIT"
EXIT:
	ld e, (ix+0)
	inc ix
	ld d, (ix+0)
	inc ix
	call RST_next


name_LIT:
	DEFW name_EXIT
	DEFM 3, "LIT"
LIT:
	ex de, hl
	ld e, (hl)
	inc hl
	ld d, (hl)
	inc hl
	ex de, hl
	push hl
	call RST_next


name_STORE:
	DEFW name_LIT
	DEFM 1, "!"
STORE:
	pop hl ;address to store at
	pop bc ;data to store
	ld (hl), c
	inc hl
	ld (hl), b
	call RST_next


name_FETCH:
	DEFW name_STORE
	DEFM 1, "@"
FETCH:
	pop hl
	ld c, (hl)
	inc hl
	ld b, (hl)
	push bc
	call RST_next


name_ADDSTORE:
	DEFW name_FETCH
	DEFM 2, "+!"
ADDSTORE:
	pop hl ;address
	pop bc ;amount to add
	ld a, c
	add a, (hl)
	ld (hl), a
	inc hl
	ld a, b
	adc a, (hl)
	ld (hl), a
	call RST_next


name_SUBSTORE:
	DEFW name_ADDSTORE
	DEFM 2, "-!"
SUBSTORE:
	pop hl ;address
	pop bc ;amount to subtract
	ld a, c
	sub a, (hl)
	ld (hl), a
	inc hl
	ld a, b
	sbc a, (hl)
	ld (hl), a
	call RST_next


name_STOREBYTE:
	DEFW name_SUBSTORE
	DEFM 2, "C!"
STOREBYTE:
	pop hl ;address to store at
	pop bc ;data to store
	ld (hl), c
	call RST_next


name_FETCHBYTE:
	DEFW name_STOREBYTE
	DEFM 2, "C@"
FETCHBYTE:
	pop hl
	ld c, (hl)
	ld b, 0
	push bc
	call RST_next


name_CMOVE:
	DEFW name_FETCHBYTE
	DEFM 5, "CMOVE"
CMOVE:
	pop bc ;length
	ex de, hl ;hl = IP
	pop de ;dest
	ex (sp), hl ;IP on stack, hl = source
	ldir
	pop de ;restore IP
	call RST_next


; Variables
name_STATE:
	DEFW name_CMOVE
	DEFM 5, "STATE"
STATE:
	ld hl, var_STATE
	push hl
	call RST_next


name_HERE:
	DEFW name_STATE
	DEFM 4, "HERE"
HERE:
	ld hl, var_HERE
	push hl
	call RST_next


name_LATEST:
	DEFW name_HERE
	DEFM 6, "LATEST"
LATEST:
	ld hl, var_LATEST
	push hl
	call RST_next


name_SZ:
	DEFW name_LATEST
	DEFM 2, "S0"
SZ:
	ld hl, var_SZ
	push hl
	call RST_next


name_BASE:
	DEFW name_SZ
	DEFM 4, "BASE"
BASE:
	ld hl, var_BASE
	push hl
	call RST_next


;Constants
name_RZ:
	DEFW name_BASE
	DEFM 2, "R0"
RZ:
	ld hl, return_stack_top
	push hl
	call RST_next


name_DOCOL:
	DEFW name_RZ
	DEFM 5, "DOCOL"
DOCOL:
	ld hl, RST_docol
	push hl
	call RST_next


name_F_IMMED:
	DEFW name_DOCOL
	DEFM 7, "F_IMMED"
__F_IMMED:
	ld hl, F_IMMED
	push hl
	call RST_next


name_F_HIDDEN:
	DEFW name_F_IMMED
	DEFM 8, "F_HIDDEN"
__F_HIDDEN:
	ld hl, F_HIDDEN
	push hl
	call RST_next


name_F_LENMASK:
	DEFW name_F_HIDDEN
	DEFM 9, "F_LENMASK"
__F_LENMASK:
	ld hl, F_LENMASK
	push hl
	call RST_next


name_TOR:
	DEFW name_F_LENMASK
	DEFM 2, ">R"
TOR:
	pop hl
	dec ix
	ld (ix+0), h
	dec ix
	ld (ix+0), l
	call RST_next


name_FROMR:
	DEFW name_TOR
	DEFM 2, "R>"
FROMR:
	ld l, (ix+0)
	inc ix
	ld h, (ix+0)
	inc ix
	push hl
	call RST_next


name_RSPFETCH:
	DEFW name_FROMR
	DEFM 4, "RSP@"
RSPFETCH:
	push ix
	call RST_next


name_RSPSTORE:
	DEFW name_RSPFETCH
	DEFM 4, "RSP!"
RSPSTORE:
	pop ix
	call RST_next


name_RDROP:
	DEFW name_RSPSTORE
	DEFM 5, "RDROP"
RDROP:
	inc ix
	inc ix
	call RST_next


name_DSPFETCH:
	DEFW name_RDROP
	DEFM 4, "DSP@"
DSPFETCH:
	ld hl, 0
	add hl, sp
	push hl
	call RST_next


name_DSPSTORE:
	DEFW name_DSPFETCH
	DEFM 4, "DSP!"
DSPSTORE:
	pop hl
	ld sp, hl
	call RST_next


name_KEY:
	DEFW name_DSPSTORE
	DEFM 3, "KEY"
KEY:
	push ix
	rst RST_getc
	rst RST_putc
	pop ix
	ld h, 0
	ld l, a
	push hl
	call RST_next


name_EMIT:
	DEFW name_KEY
	DEFM 4, "EMIT"
EMIT:
	pop hl
	ld a, l
	push ix
	rst RST_putc
	pop ix
	call RST_next


name_DOT:
	DEFW name_EMIT
	DEFM 1, "."
DOT:
	pop hl
	push de
	push ix
	call printDec16
	pop ix
	pop de
	ld a, ' '
	push ix
	rst RST_putc
	pop ix
	call RST_next


name_WORD:
	DEFW name_DOT
	DEFM 4, "WORD"
WORD:
	push de
	push ix
	call _word
	pop ix
	pop de
	push hl ;address
	push bc ;length
	call RST_next

_word:
	push ix
	rst RST_getc
	rst RST_putc
	pop ix
	cp '\\'
	jr z, _word_skipComment
	cp ' '
	jr z, _word

	ld hl, word_buffer
	ld bc, 0
_word_loop:
	ld (hl), a
	inc bc
	inc hl
	push ix
	rst RST_getc
	rst RST_putc
	pop ix
	cp ' '
	jr z, _word_end
	cp '\r'
	jr z, _word_end
	cp '\n'
	jr nz, _word_loop

_word_end:
	ld hl, word_buffer
	ret

_word_skipComment:
	push ix
	rst RST_getc
	rst RST_putc
	pop ix
	cp '\n'
	jr nz, _word_skipComment
	jr _word


name_NUMBER:
	DEFW name_WORD
	DEFM 6, "NUMBER"
NUMBER:
	pop bc ;length
	pop hl ;start address of string
	push de
	call _number
	pop de
	push hl ;parsed number
	push bc ;number of unparsed characters
	call RST_next

_number:
	ex de, hl ;de = start of string
	; check if length is zero
	xor a
	ld h, a
	ld l, a
	adc hl, bc
	ld h, a
	ld l, a
	jr z, _number_zeroLength

	cp b
	ret nz
	ld b, c ;ignore MSB of length, use b as counter
	ld a, (var_BASE)
	ld c, a

	ld a, (de)
	inc de
	cp '-'
	push af ;remember zero flag for later
	jr nz, _number_parseChar
	;first char is '-'
	djnz _number_loop
	pop af
	ld c, 1 ;error, string is only "-"
	ret


_number_loop:
	;multiply hl by c
	ld a, c
	ld c, b ;save b in c
	ld b, 8
	push de
	ex de, hl
	ld hl, 0
_number_mulLoop:
	add hl, hl
	rlca
	jr nc, _number_mulLoop1
	add hl, de
_number_mulLoop1:
	djnz _number_mulLoop
	ld b, c ;restore b
	ld c, a ;restore c

	pop de
	ld a, (de)
	inc de

_number_parseChar:
	;convert the char in a into a number from 0 to 35
	sub '0'
	jr c, _number_return
	cp '9' - '0' + 1
	jr c, _number_checkBase
	sub 'A' - '0'
	jr c, _number_return
	add a, 10
_number_checkBase:
	cp c
	jr nc, _number_return

	add a, l ;add a to hl
	ld l, a
	ld a, h
	adc a, 0
	ld h, a
	djnz _number_loop

_number_return:
	ld c, b
	ld b, 0
	pop af
	ret nz
	;hl = 0 - hl
	ex de, hl
	ld hl, 0
	or a
	sbc hl, de
	ret

_number_zeroLength:
	;bc = 0
	ld h, b
	ld l, c
	ret


name_FIND:
	DEFW name_NUMBER
	DEFM 4, "FIND"
FIND:
	pop bc ;length
	pop hl ;address
	push de
	call _find
	pop de
	push hl ;address of entry or 0
	call RST_next

_find:
	ex de, hl ;de = address of string to find
	xor a
	cp b
	ld hl, 0
	ret nz ;error if length > 255
	ld hl, (var_LATEST) ;hl = current dict entry

_find_loop:
	;check if hl == 0
	xor a
	cp h
	jr nz, _find_notNull
	cp l
	jr z, _find_notFound
_find_notNull:
	inc hl
	inc hl
	ld a, (hl)
	dec hl
	dec hl
	and F_HIDDEN | F_LENMASK
	cp c ;compare length
	jr nz, _find_next

	;compare the strings
	push hl
	push de
	inc hl
	inc hl
	inc hl
	ld b, c
	;(de): string 1, (hl): string 2, b: length
_find_compareLoop:
	ld a, (de)
	cp (hl)
	jr nz, _find_nextPop
	inc hl
	inc de
	djnz _find_compareLoop
	pop de
	pop hl
	ret

_find_nextPop:
	pop de
	pop hl
_find_next:
	ld a, (hl)
	inc hl
	ld b, (hl)
	ld l, a
	ld h, b
	jr _find_loop

_find_notFound:
	ld hl, 0
	ret


name_TCFA:
	DEFW name_FIND
	DEFM 4, ">CFA"
TCFA:
	pop hl
	call _tcfa
	push hl
	call RST_next

_tcfa:
	inc hl ;skip link pointer
	inc hl
	ld a, (hl)
	and F_LENMASK
	inc a ;skip length field
	ld b, 0
	ld c, a
	add hl, bc
	ret


name_BRANCH:
	DEFW name_TCFA
	DEFM 6, "BRANCH"
BRANCH:
	ex de, hl ;hl = IP
	ld e, (hl)
	inc hl
	ld d, (hl)
	dec hl
	add hl, de ;hl = IP + offset
	ex de, hl ;de = hl (IP)
	call RST_next


name_ZBRANCH:
	DEFW name_BRANCH
	DEFM 7, "0BRANCH"
ZBRANCH:
	pop hl
	xor a
	ld b, a
	ld c, a
	sbc hl, bc
	jr z, BRANCH
	inc de
	inc de
	call RST_next


name_TYPE:
	DEFW name_ZBRANCH
	DEFM 4, "TYPE"
TYPE:
	pop bc ;length
	pop hl ;address
	call _type
	call RST_next

_type:
	inc b
_type_loop:
	ld a, (hl)
	inc hl
	push ix
	rst RST_putc
	pop ix
	dec c
	jr nz, _type_loop
	djnz _type_loop
	ret


name_BYE:
	DEFW name_TYPE
	DEFM 3, "BYE"
BYE:
	ld hl, (var_SZ)
	ld sp, hl
	ret


name_QUIT:
	DEFW name_BYE
	DEFM 4, "QUIT"
QUIT:
	call RST_docol
	DEFW RZ, RSPSTORE
	DEFW INTERPRET
	DEFW BRANCH, -4


name_INTERPRET:
	DEFW name_QUIT
	DEFM 9, "INTERPRET"
INTERPRET:
	push de
	call _word ;hl: address, bc: length
	;convert to uppercase
	push hl
	push bc
	call fstrtup
	pop bc
	pop hl
	push hl
	push bc
	call _find ;hl = address of entry or 0
	xor a
	ld b, a
	ld c, a
	sbc hl, bc
	jr z, _interpret_notInDict
	pop bc ;discard string address and length
	pop bc
	; word is in dict, if F_IMMED or state = 0: execute
	inc hl
	inc hl
	ld a, (hl)
	dec hl
	dec hl
	and F_IMMED
	jr nz, _interpret_execute

	ld bc, (var_STATE)
	cp b
	jr nz, _interpret_compile
	cp c
	jr nz, _interpret_compile
_interpret_execute:
	;jump to the word
	pop de ; IP
	call _tcfa
	jp (hl)


_interpret_compile:
	call _tcfa
	ex de, hl ;de = word
	ld hl, (var_HERE)
	ld (hl), e
	inc hl
	ld (hl), d
	inc hl
	ld (var_HERE), hl
	pop de
	call RST_next

_interpret_notInDict:
	pop bc
	pop hl
	call _number
	;hl: parsed number, bc: unparsed characters
	xor a
	cp b
	jr nz, _interpret_error
	cp c
	jr nz, _interpret_error
	; word is a number
	ld bc, (var_STATE)
	cp b
	jr z, _interpret_pushLit
	cp c
	jr nz, _interpret_compileLit
_interpret_pushLit:
	pop de
	push hl
	call RST_next

_interpret_compileLit:
	ex de, hl ;de = number
	ld bc, LIT
	ld hl, (var_HERE)
	ld (hl), c
	inc hl
	ld (hl), b
	inc hl
	ld (hl), e
	inc hl
	ld (hl), d
	inc hl
	ld (var_HERE), hl
	call RST_next

_interpret_error:
	ld hl, errmsg
	call print
	pop de
	call RST_next


name_CREATE:
	DEFW name_INTERPRET
	DEFM 6, "CREATE"
CREATE:
	pop bc ;string length
	pop hl ;string address
	push de
	ex de, hl ;de = string addr
	ld hl, (var_HERE)
	ld a, (var_LATEST)
	ld (hl), a
	inc hl
	ld a, (var_LATEST + 1)
	ld (hl), a
	inc hl
	ld (hl), c
	inc hl
	ex de, hl ;hl = string, de = new entry
	ldir

	ld hl, (var_HERE)
	ld (var_LATEST), hl
	ld (var_HERE), de
	pop de
	call RST_next


name_COMMA:
	DEFW name_CREATE
	DEFM 1, ","
COMMA:
	pop bc
	ld hl, (var_HERE)
	ld (hl), c
	inc hl
	ld (hl), b
	inc hl
	ld (var_HERE), hl
	call RST_next


name_CCOMMA:
	DEFW name_COMMA
	DEFM 2, "C,"
CCOMMA:
	pop bc
	ld hl, (var_HERE)
	ld (hl), c
	inc hl
	ld (var_HERE), hl
	call RST_next


name_LBRAC:
	DEFW name_CCOMMA
	DEFM 1 | F_IMMED, "["
LBRAC:
	xor a
	ld (var_STATE), a
	ld (var_STATE + 1), a
	call RST_next


name_RBRAC:
	DEFW name_LBRAC
	DEFM 1, "]"
RBRAC:
	xor a
	ld (var_STATE + 1), a
	inc a
	ld (var_STATE), a
	call RST_next


name_IMMEDIATE:
	DEFW name_RBRAC
	DEFM 9, "IMMEDIATE"
IMMEDIATE:
	ld hl, (var_LATEST)
	inc hl
	inc hl
	ld a, F_IMMED
	xor (hl)
	ld (hl), a
	call RST_next


name_HIDDEN:
	DEFW name_IMMEDIATE
	DEFM 6, "HIDDEN"
HIDDEN:
	pop hl
	inc hl
	inc hl
	ld a, F_HIDDEN
	xor (hl)
	ld (hl), a
	call RST_next


name_HIDE:
	DEFW name_HIDDEN
	DEFM 4, "HIDE"
HIDE:
	call RST_docol
	DEFW WORD, FIND, HIDDEN, EXIT


name_TICK:
	DEFW name_HIDE
	DEFM 1, "'"
TICK:
	ld a, (de)
	ld l, a
	inc de
	ld a, (de)
	ld h, a
	inc de
	push hl
	call RST_next


name_COLON:
	DEFW name_TICK
	DEFM 1, ":"
COLON:
	call RST_docol
	DEFW WORD, CREATE
	DEFW LIT, 0xCD, CCOMMA ;call instruction
	DEFW LIT, RST_docol, COMMA ;TODO change to single rst
	DEFW LATEST, FETCH, HIDDEN
	DEFW RBRAC, EXIT


latestWord:
name_SEMICOLON:
	DEFW name_COLON
	DEFM 1 | F_IMMED, ";"
SEMICOLON:
	call RST_docol
	DEFW LIT, EXIT, COMMA
	DEFW LATEST, FETCH, HIDDEN
	DEFW LBRAC, EXIT


fstrtup:
	inc b
fstrtup_loop:
	ld a, (hl)
	call toupper
	ld (hl), a
	inc hl
	dec c
	jr nz, fstrtup_loop
	djnz fstrtup_loop
	ret


errmsg:
	DEFM "\nError\n", 0

SECTION ram_os

word_buffer:
	DEFS 32

var_STATE:
	DEFS 2
var_HERE:
	DEFS 2
var_LATEST:
	DEFS 2
var_SZ:
	DEFS 2
var_BASE:
	DEFS 2


return_stack:
	DEFS 256
return_stack_top:
