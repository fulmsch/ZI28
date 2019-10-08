; ===============================================
; CAMEL80.AZM: Code Primitives
;   Source code is for the Z80MR macro assembler.
;   Forth words are documented as follows:
;x   NAME     stack -- stack    description
;   where x=C for ANS Forth Core words, X for ANS
;   Extensions, Z for internal or private words.
;
; Direct-Threaded Forth model for Zilog Z80
; 16 bit cell, 8 bit char, 8 bit (byte) adrs unit
;    Z80 BC = Forth TOS (top Param Stack item)
;        HL =       W    working register
;        DE =       IP   Interpreter Pointer
;        SP =       PSP  Param Stack Pointer
;        IX =       RSP  Return Stack Pointer
;        IY =       UP   User area Pointer
;    A, alternate register set = temporaries

; INTERPRETER LOGIC =============================
; See also "defining words" at end of this file

;C EXIT     --      exit a colon definition
    defcode EXIT,4,exit,0
	ld e,(ix+0)    ; pop old IP from ret stk
	inc ix
	ld d,(ix+0)
	inc ix
	next

;Z LIT      -- x    fetch inline literal to stack
; This is the primtive compiled by LITERAL.
    defcode LIT,3,lit,0
	push bc        ; push old TOS
	ld a,(de)      ; fetch cell at IP to TOS,
	ld c,a         ;        advancing IP
	inc de
	ld a,(de)
	ld b,a
	inc de
	next

;C EXECUTE   i*x xt -- j*x   execute Forth word
;C                           at 'xt'
    defcode EXECUTE,7,execute,0
	ld h,b          ; address of word -> HL
	ld l,c
	pop bc          ; get new TOS
	jp (hl)         ; go do Forth word

; DEFINING WORDS ================================

; ENTER, a.k.a. DOCOLON, entered by CALL ENTER
; to enter a new high-level thread (colon def'n.)
; (internal code fragment, not a Forth word)
; N.B.: DOCOLON must be defined before any
; appearance of 'docolon' in a 'word' macro!
docolon:               ; (alternate name)
enter:  dec ix         ; push old IP on ret stack
	ld (ix+0),d
	dec ix
	ld (ix+0),e
	pop hl         ; param field adrs -> IP
	nexthl         ; use the faster 'nexthl'

;C VARIABLE   --      define a Forth variable
;   CREATE 1 CELLS ALLOT ;
; Action of RAM variable is identical to CREATE,
; so we don't need a DOES> clause to change it.
    defword VARIABLE,8,variable,0
	dw CREATE,LIT,1,CELLS,ALLOT,EXIT
; DOVAR, code action of VARIABLE, entered by CALL
; DOCREATE, code action of newly created words
docreate:
dovar:  ; -- a-addr
	pop hl     ; parameter field address
	push bc    ; push old TOS
	ld b,h     ; pfa = variable's adrs -> TOS
	ld c,l
	next

;C CONSTANT   n --      define a Forth constant
;   CREATE , DOES> (machine code fragment)
    defword CONSTANT,8,constant,0
	dw CREATE,COMMA,XDOES
; DOCON, code action of CONSTANT,
; entered by CALL DOCON
docon:  ; -- x
	pop hl     ; parameter field address
	push bc    ; push old TOS
	ld c,(hl)  ; fetch contents of parameter
	inc hl     ;    field -> TOS
	ld b,(hl)
	next

;Z USER     n --        define user variable 'n'
;   CREATE , DOES> (machine code fragment)
    defword USER,4,user,0
	dw CREATE,COMMA,XDOES
; DOUSER, code action of USER,
; entered by CALL DOUSER
douser:  ; -- a-addr
	pop hl     ; parameter field address
	push bc    ; push old TOS
	ld c,(hl)  ; fetch contents of parameter
	inc hl     ;    field
	ld b,(hl)
	push iy    ; copy user base address to HL
	pop hl
	add hl,bc  ;    and add offset
	ld b,h     ; put result in TOS
	ld c,l
	next

; DODOES, code action of DOES> clause
; entered by       CALL fragment
;                  parameter field
;                       ...
;        fragment: CALL DODOES
;                  high-level thread
; Enters high-level thread with address of
; parameter field on top of stack.
; (internal code fragment, not a Forth word)
dodoes: ; -- a-addr
	dec ix         ; push old IP on ret stk
	ld (ix+0),d
	dec ix
	ld (ix+0),e
	pop de         ; adrs of new thread -> IP
	pop hl         ; adrs of parameter field
	push bc        ; push old TOS onto stack
	ld b,h         ; pfa -> new TOS
	ld c,l
	next

;C EMIT     c --    output character to console
    defcode EMIT,4,emit,0
	ld a, c      ; grab the character from TOS, put in A
	pop bc       ; pop it off the stack
	rst 0x08     ; call SBC TXA to output to serial
	next

;X KEY?     -- f    return true if char waiting
    defcode QUERYKEY,4,key?,0
	rst 0x18     ; call SBC CHKINCHAR on serial
	push bc      ; push old TOS
	ld b, 0
	ld c, a      ; push flag on TOS
	next

;C KEY      -- c    get character from keyboard
    defcode KEY,3,key,0
	rst 0x10       ; call SBC RXA to read from serial
	push bc           ; push TOS down
	ld b, 0
	ld c, a           ; move char from A to BC
	out (0x80), a   ; set new ACIA status
	next

; STACK OPERATIONS ==============================

;C DUP      x -- x x      duplicate top of stack
    defcode DUP,3,dup,0
pushtos: push bc
	next

;C ?DUP     x -- 0 | x x    DUP if nonzero
    defcode QDUP,4,?dup,0
	ld a,b
	or c
	jr nz,pushtos
	next

;C DROP     x --          drop top of stack
    defcode DROP,4,drop,0
poptos: pop bc
	next

;C SWAP     x1 x2 -- x2 x1    swap top two items
    defcode SWOP,4,swap,0
	pop hl
	push bc
	ld b,h
	ld c,l
	next

;C OVER    x1 x2 -- x1 x2 x1   per stack diagram
    defcode OVER,4,over,0
	pop hl
	push hl
	push bc
	ld b,h
	ld c,l
	next

;C ROT    x1 x2 x3 -- x2 x3 x1  per stack diagram
    defcode ROT,3,rot,0
	; x3 is in TOS
	pop hl          ; x2
	ex (sp),hl      ; x2 on stack, x1 in hl
	push bc
	ld b,h
	ld c,l
	next

;X NIP    x1 x2 -- x2           per stack diagram
    defword NIP,3,nip,0
	dw SWOP,DROP,EXIT

;X TUCK   x1 x2 -- x2 x1 x2     per stack diagram
    defword TUCK,4,tuck,0
	dw SWOP,OVER,EXIT

;C >R    x --   R: -- x   push to return stack
    defcode TOR,2,>r,0
	dec ix          ; push TOS onto rtn stk
	ld (ix+0),b
	dec ix
	ld (ix+0),c
	pop bc          ; pop new TOS
	next

;C R>    -- x    R: x --   pop from return stack
    defcode RFROM,2,r>,0
	push bc         ; push old TOS
	ld c,(ix+0)     ; pop top rtn stk item
	inc ix          ;       to TOS
	ld b,(ix+0)
	inc ix
	next

;C R@    -- x     R: x -- x   fetch from rtn stk
    defcode RFETCH,2,r@,0
	push bc         ; push old TOS
	ld c,(ix+0)     ; fetch top rtn stk item
	ld b,(ix+1)     ;       to TOS
	next

;Z SP@  -- a-addr       get data stack pointer
    defcode SPFETCH,3,sp@,0
	push bc
	ld hl,0
	add hl,sp
	ld b,h
	ld c,l
	next

;Z SP!  a-addr --       set data stack pointer
    defcode SPSTORE,3,sp!,0
	ld h,b
	ld l,c
	ld sp,hl
	pop bc          ; get new TOS
	next

;Z RP@  -- a-addr       get return stack pointer
    defcode RPFETCH,3,rp@,0
	push bc
	push ix
	pop bc
	next

;Z RP!  a-addr --       set return stack pointer
    defcode RPSTORE,3,rp!,0
	push bc
	pop ix
	pop bc
	next

; MEMORY AND I/O OPERATIONS =====================

;C !        x a-addr --   store cell in memory
    defcode STORE,1,!,0
	ld h,b          ; address in hl
	ld l,c
	pop bc          ; data in bc
	ld (hl),c
	inc hl
	ld (hl),b
	pop bc          ; pop new TOS
	next

;C C!      char c-addr --    store char in memory
    defcode CSTORE,2,c!,0
	ld h,b          ; address in hl
	ld l,c
	pop bc          ; data in bc
	ld (hl),c
	pop bc          ; pop new TOS
	next

;C @       a-addr -- x   fetch cell from memory
    defcode FETCH,1,@,0
	ld h,b          ; address in hl
	ld l,c
	ld c,(hl)
	inc hl
	ld b,(hl)
	next

;C C@     c-addr -- char   fetch char from memory
    defcode CFETCH,2,c@,0
	ld a,(bc)
	ld c,a
	ld b,0
	next

;Z PC!     char c-addr --    output char to port
    defcode PCSTORE,3,pc!,0
	pop hl          ; char in L
	out (c),l       ; to port (BC)
	pop bc          ; pop new TOS
	next

;Z PC@     c-addr -- char   input char from port
    defcode PCFETCH,3,pc@,0
	in c,(c)        ; read port (BC) to C
	ld b,0
	next

; ARITHMETIC AND LOGICAL OPERATIONS =============

;C +       n1/u1 n2/u2 -- n3/u3     add n1+n2
    defcode PLUS,1,+,0
	pop hl
	add hl,bc
	ld b,h
	ld c,l
	next

;X M+       d n -- d         add single to double
    defcode MPLUS,2,m+,0
	ex de,hl
	pop de          ; hi cell
	ex (sp),hl      ; lo cell, save IP
	add hl,bc
	ld b,d          ; hi result in BC (TOS)
	ld c,e
	jr nc,mplus1
	inc bc
mplus1: pop de          ; restore saved IP
	push hl         ; push lo result
	next

;C -      n1/u1 n2/u2 -- n3/u3    subtract n1-n2
    defcode MINUS,1,-,0
	pop hl
	or a
	sbc hl,bc
	ld b,h
	ld c,l
	next

;C AND    x1 x2 -- x3            logical AND
    defcode AND,3,and,0
	pop hl
	ld a,b
	and h
	ld b,a
	ld a,c
	and l
	ld c,a
	next

;C OR     x1 x2 -- x3           logical OR
    defcode OR,2,or,0
	pop hl
	ld a,b
	or h
	ld b,a
	ld a,c
	or l
	ld c,a
	next

;C XOR    x1 x2 -- x3            logical XOR
    defcode XOR,3,xor,0
	pop hl
	ld a,b
	xor h
	ld b,a
	ld a,c
	xor l
	ld c,a
	next

;C INVERT   x1 -- x2            bitwise inversion
    defcode INVERT,6,invert,0
	ld a,b
	cpl
	ld b,a
	ld a,c
	cpl
	ld c,a
	next

;C NEGATE   x1 -- x2            two's complement
    defcode NEGATE,6,negate,0
	ld a,b
	cpl
	ld b,a
	ld a,c
	cpl
	ld c,a
	inc bc
	next

;C 1+      n1/u1 -- n2/u2       add 1 to TOS
    defcode ONEPLUS,2,1+,0
	inc bc
	next

;C 1-      n1/u1 -- n2/u2     subtract 1 from TOS
    defcode ONEMINUS,2,1-,0
	dec bc
	next

;Z ><      x1 -- x2         swap bytes (not ANSI)
    defcode swapbytes,2,><,0
	ld a,b
	ld b,c
	ld c,a
	next

;C 2*      x1 -- x2         arithmetic left shift
    defcode TWOSTAR,2,2*,0
	sla c
	rl b
	next

;C 2/      x1 -- x2        arithmetic right shift
    defcode TWOSLASH,2,2/,0
	sra b
	rr c
	next

;C LSHIFT  x1 u -- x2    logical L shift u places
    defcode LSHIFT,6,lshift,0
	ld b,c        ; b = loop counter
	pop hl        ;   NB: hi 8 bits ignored!
	inc b         ; test for counter=0 case
	jr lsh2
lsh1:   add hl,hl     ; left shift HL, n times
lsh2:   djnz lsh1
	ld b,h        ; result is new TOS
	ld c,l
	next

;C RSHIFT  x1 u -- x2    logical R shift u places
    defcode RSHIFT,6,rshift,0
	ld b,c        ; b = loop counter
	pop hl        ;   NB: hi 8 bits ignored!
	inc b         ; test for counter=0 case
	jr rsh2
rsh1:   srl h         ; right shift HL, n times
	rr l
rsh2:   djnz rsh1
	ld b,h        ; result is new TOS
	ld c,l
	next

;C +!     n/u a-addr --       add cell to memory
    defcode PLUSSTORE,2,+!,0
	pop hl
	ld a,(bc)       ; low byte
	add a,l
	ld (bc),a
	inc bc
	ld a,(bc)       ; high byte
	adc a,h
	ld (bc),a
	pop bc          ; pop new TOS
	next

; COMPARISON OPERATIONS =========================

;C 0=     n/u -- flag    return true if TOS=0
    defcode ZEROEQUAL,2,0=,0
	ld a,b
	or c            ; result=0 if bc was 0
	sub 1           ; cy set   if bc was 0
	sbc a,a         ; propagate cy through A
	ld b,a          ; put 0000 or FFFF in TOS
	ld c,a
	next

;C 0<     n -- flag      true if TOS negative
    defcode ZEROLESS,2,<0<>,0
	sla b           ; sign bit -> cy flag
	sbc a,a         ; propagate cy through A
	ld b,a          ; put 0000 or FFFF in TOS
	ld c,a
	next

;C =      x1 x2 -- flag         test x1=x2
    defcode EQUAL,1,=,0
	pop hl
	or a
	sbc hl,bc       ; x1-x2 in HL, SZVC valid
	jr z,tostrue
tosfalse: ld bc,0
	next

;X <>     x1 x2 -- flag    test not eq (not ANSI)
    defword NOTEQUAL,2,<<>>,0
	dw EQUAL,ZEROEQUAL,EXIT

;C <      n1 n2 -- flag        test n1<n2, signed
    defcode LESS,1,<<>,0
	pop hl
	or a
	sbc hl,bc       ; n1-n2 in HL, SZVC valid
; if result negative & not OV, n1<n2
; neg. & OV => n1 +ve, n2 -ve, rslt -ve, so n1>n2
; if result positive & not OV, n1>=n2
; pos. & OV => n1 -ve, n2 +ve, rslt +ve, so n1<n2
; thus OV reverses the sense of the sign bit
	jp pe,revsense  ; if OV, use rev. sense
	jp p,tosfalse   ;   if +ve, result false
tostrue: ld bc,0xffff   ;   if -ve, result true
	next
revsense: jp m,tosfalse ; OV: if -ve, reslt false
	jr tostrue      ;     if +ve, result true

;C >     n1 n2 -- flag         test n1>n2, signed
    defword GREATER,1,>,0
	dw SWOP,LESS,EXIT

;C U<    u1 u2 -- flag       test u1<n2, unsigned
    defcode ULESS,2,<u<>,0
	pop hl
	or a
	sbc hl,bc       ; u1-u2 in HL, SZVC valid
	sbc a,a         ; propagate cy through A
	ld b,a          ; put 0000 or FFFF in TOS
	ld c,a
	next

;X U>    u1 u2 -- flag     u1>u2 unsgd (not ANSI)
    defword UGREATER,2,<u>>,0
	dw SWOP,ULESS,EXIT

; LOOP AND BRANCH OPERATIONS ====================

;Z branch   --                  branch always
    defcode BRANCH,6,branch,0
dobranch: ld a,(de)     ; get inline value => IP
	ld l,a
	inc de
	ld a,(de)
	ld h,a
	nexthl

;Z ?branch   x --              branch if TOS zero
    defcode QBRANCH,7,?branch,0
	ld a,b
	or c            ; test old TOS
	pop bc          ; pop new TOS
	jr z,dobranch   ; if old TOS=0, branch
	inc de          ; else skip inline value
	inc de
	next

;Z (do)    n1|u1 n2|u2 --  R: -- sys1 sys2
;Z                          run-time code for DO
; '83 and ANSI standard loops terminate when the
; boundary of limit-1 and limit is crossed, in
; either direction.  This can be conveniently
; implemented by making the limit 0x8000, so that
; arithmetic overflow logic can detect crossing.
; I learned this trick from Laxen & Perry F83.
; fudge factor = 0x8000-limit, to be added to
; the start value.
    defcode XDO,4,<(do)>,0
	ex de,hl
	ex (sp),hl   ; IP on stack, limit in HL
	ex de,hl
	ld hl,0x8000
	or a
	sbc hl,de    ; 8000-limit in HL
	dec ix       ; push this fudge factor
	ld (ix+0),h  ;    onto return stack
	dec ix       ;    for later use by 'I'
	ld (ix+0),l
	add hl,bc    ; add fudge to start value
	dec ix       ; push adjusted start value
	ld (ix+0),h  ;    onto return stack
	dec ix       ;    as the loop index.
	ld (ix+0),l
	pop de       ; restore the saved IP
	pop bc       ; pop new TOS
	next

;Z (loop)   R: sys1 sys2 --  | sys1 sys2
;Z                        run-time code for LOOP
; Add 1 to the loop index.  If loop terminates,
; clean up the return stack and skip the branch.
; Else take the inline branch.  Note that LOOP
; terminates when index=0x8000.
    defcode XLOOP,6,<(loop)>,0
	exx
	ld bc,1
looptst: ld l,(ix+0)  ; get the loop index
	ld h,(ix+1)
	or a
	adc hl,bc    ; increment w/overflow test
	jp pe,loopterm  ; overflow=loop done
	; continue the loop
	ld (ix+0),l  ; save the updated index
	ld (ix+1),h
	exx
	jr dobranch  ; take the inline branch
loopterm: ; terminate the loop
	ld bc,4      ; discard the loop info
	add ix,bc
	exx
	inc de       ; skip the inline branch
	inc de
	next

;Z (+loop)   n --   R: sys1 sys2 --  | sys1 sys2
;Z                        run-time code for +LOOP
; Add n to the loop index.  If loop terminates,
; clean up the return stack and skip the branch.
; Else take the inline branch.
    defcode XPLUSLOOP,7,<(+loop)>,0
	pop hl      ; this will be the new TOS
	push bc
	ld b,h
	ld c,l
	exx
	pop bc      ; old TOS = loop increment
	jr looptst

;C I        -- n   R: sys1 sys2 -- sys1 sys2
;C                  get the innermost loop index
    defcode II,1,i,0
	push bc     ; push old TOS
	ld l,(ix+0) ; get current loop index
	ld h,(ix+1)
	ld c,(ix+2) ; get fudge factor
	ld b,(ix+3)
	or a
	sbc hl,bc   ; subtract fudge factor,
	ld b,h      ;   returning true index
	ld c,l
	next

;C J        -- n   R: 4*sys -- 4*sys
;C                  get the second loop index
    defcode JJ,1,j,0
	push bc     ; push old TOS
	ld l,(ix+4) ; get current loop index
	ld h,(ix+5)
	ld c,(ix+6) ; get fudge factor
	ld b,(ix+7)
	or a
	sbc hl,bc   ; subtract fudge factor,
	ld b,h      ;   returning true index
	ld c,l
	next

;C UNLOOP   --   R: sys1 sys2 --  drop loop parms
    defcode UNLOOP,6,unloop,0
	inc ix
	inc ix
	inc ix
	inc ix
	next

; MULTIPLY AND DIVIDE ===========================

;C UM*     u1 u2 -- ud   unsigned 16x16->32 mult.
    defcode UMSTAR,3,um*,0
	push bc
	exx
	pop bc      ; u2 in BC
	pop de      ; u1 in DE
	ld hl,0     ; result will be in HLDE
	ld a,17     ; loop counter
	or a        ; clear cy
umloop: rr h
	rr l
	rr d
	rr e
	jr nc,noadd
	add hl,bc
noadd:  dec a
	jr nz,umloop
	push de     ; lo result
	push hl     ; hi result
	exx
	pop bc      ; put TOS back in BC
	next

;C UM/MOD   ud u1 -- u2 u3   unsigned 32/16->16
    defcode UMSLASHMOD,6,um/mod,0
	push bc
	exx
	pop bc      ; BC = divisor
	pop hl      ; HLDE = dividend
	pop de
	ld a,16     ; loop counter
	sla e
	rl d        ; hi bit DE -> carry
udloop: adc hl,hl   ; rot left w/ carry
	jr nc,udiv3
	; case 1: 17 bit, cy:HL = 1xxxx
	or a        ; we know we can subtract
	sbc hl,bc
	or a        ; clear cy to indicate sub ok
	jr udiv4
	; case 2: 16 bit, cy:HL = 0xxxx
udiv3:  sbc hl,bc   ; try the subtract
	jr nc,udiv4 ; if no cy, subtract ok
	add hl,bc   ; else cancel the subtract
	scf         ;   and set cy to indicate
udiv4:  rl e        ; rotate result bit into DE,
	rl d        ; and next bit of DE into cy
	dec a
	jr nz,udloop
	; now have complemented quotient in DE,
	; and remainder in HL
	ld a,d
	cpl
	ld b,a
	ld a,e
	cpl
	ld c,a
	push hl     ; push remainder
	push bc
	exx
	pop bc      ; quotient remains in TOS
	next

; BLOCK AND STRING OPERATIONS ===================

;C FILL   c-addr u char --  fill memory with char
    defcode FILL,4,fill,0
	ld a,c          ; character in a
	exx             ; use alt. register set
	pop bc          ; count in bc
	pop de          ; address in de
	or a            ; clear carry flag
	ld hl,0xffff
	adc hl,bc       ; test for count=0 or 1
	jr nc,filldone  ;   no cy: count=0, skip
	ld (de),a       ; fill first byte
	jr z,filldone   ;   zero, count=1, done
	dec bc          ; else adjust count,
	ld h,d          ;   let hl = start adrs,
	ld l,e
	inc de          ;   let de = start adrs+1
	ldir            ;   copy (hl)->(de)
filldone: exx           ; back to main reg set
	pop bc          ; pop new TOS
	next

;X CMOVE   c-addr1 c-addr2 u --  move from bottom
; as defined in the ANSI optional String word set
; On byte machines, CMOVE and CMOVE> are logical
; factors of MOVE.  They are easy to implement on
; CPUs which have a block-move instruction.
    defcode CMOVE,5,cmove,0
	push bc
	exx
	pop bc      ; count
	pop de      ; destination adrs
	pop hl      ; source adrs
	ld a,b      ; test for count=0
	or c
	jr z,cmovedone
	ldir        ; move from bottom to top
cmovedone: exx
	pop bc      ; pop new TOS
	next

;X CMOVE>  c-addr1 c-addr2 u --  move from top
; as defined in the ANSI optional String word set
    defcode CMOVEUP,6,cmove>,0
	push bc
	exx
	pop bc      ; count
	pop hl      ; destination adrs
	pop de      ; source adrs
	ld a,b      ; test for count=0
	or c
	jr z,umovedone
	add hl,bc   ; last byte in destination
	dec hl
	ex de,hl
	add hl,bc   ; last byte in source
	dec hl
	lddr        ; move from top to bottom
umovedone: exx
	pop bc      ; pop new TOS
	next

;Z SKIP   c-addr u c -- c-addr' u'
;Z                          skip matching chars
; Although SKIP, SCAN, and S= are perhaps not the
; ideal factors of WORD and FIND, they closely
; follow the string operations available on many
; CPUs, and so are easy to implement and fast.
    defcode SKIP,4,skip,0
	ld a,c      ; skip character
	exx
	pop bc      ; count
	pop hl      ; address
	ld e,a      ; test for count=0
	ld a,b
	or c
	jr z,skipdone
	ld a,e
skiploop: cpi
	jr nz,skipmis   ; char mismatch: exit
	jp pe,skiploop  ; count not exhausted
	jr skipdone     ; count 0, no mismatch
skipmis: inc bc         ; mismatch!  undo last to
	dec hl          ;  point at mismatch char
skipdone: push hl   ; updated address
	push bc     ; updated count
	exx
	pop bc      ; TOS in bc
	next

;Z SCAN    c-addr u c -- c-addr' u'
;Z                      find matching char
    defcode SCAN,4,scan,0
	ld a,c      ; scan character
	exx
	pop bc      ; count
	pop hl      ; address
	ld e,a      ; test for count=0
	ld a,b
	or c
	jr z,scandone
	ld a,e
	cpir        ; scan 'til match or count=0
	jr nz,scandone  ; no match, BC & HL ok
	inc bc          ; match!  undo last to
	dec hl          ;   point at match char
scandone: push hl   ; updated address
	push bc     ; updated count
	exx
	pop bc      ; TOS in bc
	next

;Z S=    c-addr1 c-addr2 u -- n   string compare
;Z             n<0: s1<s2, n=0: s1=s2, n>0: s1>s2
    defcode SEQUAL,2,s=,0
	push bc
	exx
	pop bc      ; count
	pop hl      ; addr2
	pop de      ; addr1
	ld a,b      ; test for count=0
	or c
	jr z,smatch     ; by definition, match!
sloop:  ld a,(de)
	inc de
	cpi
	jr nz,sdiff     ; char mismatch: exit
	jp pe,sloop     ; count not exhausted
smatch: ; count exhausted & no mismatch found
	exx
	ld bc,0         ; bc=0000  (s1=s2)
	jr snext
sdiff:  ; mismatch!  undo last 'cpi' increment
	dec hl          ; point at mismatch char
	cp (hl)         ; set cy if char1 < char2
	sbc a,a         ; propagate cy thru A
	exx
	ld b,a          ; bc=FFFF if cy (s1<s2)
	or 1            ; bc=0001 if ncy (s1>s2)
	ld c,a
snext:  next

; ===============================================
; CAMEL80D.AZM: CPU and Model Dependencies
;   Source code is for the Z80MR macro assembler.
;   Forth words are documented as follows:
;*   NAME     stack -- stack    description
;   Word names in upper case are from the ANS
;   Forth Core word set.  Names in lower case are
;   "internal" implementation words & extensions.
;
; Direct-Threaded Forth model for Zilog Z80
;   cell size is   16 bits (2 bytes)
;   char size is    8 bits (1 byte)
;   address unit is 8 bits (1 byte), i.e.,
;       addresses are byte-aligned.
; ===============================================

; ALIGNMENT AND PORTABILITY OPERATORS ===========
; Many of these are synonyms for other words,
; and so are defined as CODE words.

;C ALIGN    --                         align HERE
    defcode ALIGN,5,align,0
noop:   next

;C ALIGNED  addr -- a-addr       align given addr
    defcode ALIGNED,7,aligned,0
	jr noop

;Z CELL     -- n                 size of one cell
    defconst CELL,4,cell,0,2

;C CELL+    a-addr1 -- a-addr2      add cell size
;   2 + ;
    defcode CELLPLUS,5,cell+,0
	inc bc
	inc bc
	next

;C CELLS    n1 -- n2            cells->adrs units
    defcode CELLS,5,cells,0
	jp TWOSTAR

;C CHAR+    c-addr1 -- c-addr2   add char size
    defcode CHARPLUS,5,char+,0
	jp ONEPLUS

;C CHARS    n1 -- n2            chars->adrs units
    defcode CHARS,5,chars,0
	jr noop

;C >BODY    xt -- a-addr      adrs of param field
;   3 + ;                     Z80 (3 byte CALL)
    defword TOBODY,5,>body,0
	dw LIT,3,PLUS,EXIT

;X COMPILE,  xt --         append execution token
; I called this word ,XT before I discovered that
; it is defined in the ANSI standard as COMPILE,.
; On a DTC Forth this simply appends xt (like , )
; but on an STC Forth this must append 'CALL xt'.
    defcode COMMAXT,8,<compile,>,0
	jp COMMA

;Z !CF    adrs cfa --   set code action of a word
;   0CD OVER C!         store 'CALL adrs' instr
;   1+ ! ;              Z80 VERSION
; Depending on the implementation this could
; append CALL adrs or JUMP adrs.
    defword STORECF,3,!cf,0
	dw LIT,0CDH,OVER,CSTORE
	dw ONEPLUS,STORE,EXIT

;Z ,CF    adrs --       append a code field
;   HERE !CF 3 ALLOT ;  Z80 VERSION (3 bytes)
    defword COMMACF,3,<,cf>,0
	dw HERE,STORECF,LIT,3,ALLOT,EXIT

;Z !COLON   --      change code field to docolon
;   -3 ALLOT docolon-adrs ,CF ;
; This should be used immediately after CREATE.
; This is made a distinct word, because on an STC
; Forth, colon definitions have no code field.
    defword STORCOLON,6,<!colon>,0
	dw LIT,-3,ALLOT
	dw LIT,docolon,COMMACF,EXIT

;Z ,EXIT    --      append hi-level EXIT action
;   ['] EXIT ,XT ;
; This is made a distinct word, because on an STC
; Forth, it appends a RET instruction, not an xt.
    defword CEXIT,5,<,exit>,0
	dw LIT,EXIT,COMMAXT,EXIT

; CONTROL STRUCTURES ============================
; These words allow Forth control structure words
; to be defined portably.

;Z ,BRANCH   xt --    append a branch instruction
; xt is the branch operator to use, e.g. qbranch
; or (loop).  It does NOT append the destination
; address.  On the Z80 this is equivalent to ,XT.
    defcode COMMABRANCH,7,<,branch>,0
	jp COMMA

;Z ,DEST   dest --        append a branch address
; This appends the given destination address to
; the branch instruction.  On the Z80 this is ','
; ...other CPUs may use relative addressing.
    defcode COMMADEST,5,<,dest>,0
	jp COMMA

;Z !DEST   dest adrs --    change a branch dest'n
; Changes the destination address found at 'adrs'
; to the given 'dest'.  On the Z80 this is '!'
; ...other CPUs may need relative addressing.
    defcode STOREDEST,5,<!dest>,0
	jp STORE

; HEADER STRUCTURE ==============================
; The structure of the Forth dictionary headers
; (name, link, immediate flag, and "smudge" bit)
; does not necessarily differ across CPUs.  This
; structure is not easily factored into distinct
; "portable" words; instead, it is implicit in
; the definitions of FIND and CREATE, and also in
; NFA>LFA, NFA>CFA, IMMED?, IMMEDIATE, HIDE, and
; REVEAL.  These words must be (substantially)
; rewritten if either the header structure or its
; inherent assumptions are changed.

; ===============================================
; CAMEL80H.AZM: High Level Words
;   Source code is for the Z80MR macro assembler.
;   Forth words are documented as follows:
;*   NAME     stack -- stack    description
;   Word names in upper case are from the ANS
;   Forth Core word set.  Names in lower case are
;   "internal" implementation words & extensions.
; ===============================================

; SYSTEM VARIABLES & CONSTANTS ==================

;C BL      -- char            an ASCII space
    defconst BL,2,bl,0,0x20

;Z tibsize  -- n         size of TIB
    defconst TIBSIZE,7,tibsize,0,124 ; 2 chars safety zone

;X tib     -- a-addr     Terminal Input Buffer
;  HEX -80 USER TIB      others: below user area
    defvar TIB,3,tib,0,-0x80

;Z u0      -- a-addr       current user area adrs
;  0 USER U0
    defvar U0,2,u0,0,0

;C >IN     -- a-addr        holds offset into TIB
;  2 USER >IN
    defvar TOIN,3,>in,0,2

;C BASE    -- a-addr       holds conversion radix
;  4 USER BASE
    defvar BASE,4,base,0,4

;C STATE   -- a-addr       holds compiler state
;  6 USER STATE
    defvar STATE,5,state,0,6

;Z dp      -- a-addr       holds dictionary ptr
;  8 USER DP
    defvar DP,2,dp,0,8

;Z 'source  -- a-addr      two cells: len, adrs
; 10 USER 'SOURCE
;    defvar TICKSOURCE,7,'source,0
	dw link                 ; must expand
	db 0                    ; manually
link    defl $                  ; because of
	db 7,0x27,'source'       ; tick character
TICKSOURCE: call douser         ; in name!
	dw 10

;Z latest    -- a-addr     last word in dict.
;   14 USER LATEST
    defvar LATEST,6,latest,0,14

;Z hp       -- a-addr     HOLD pointer
;   16 USER HP
    defvar HP,2,hp,0,16

;Z LP       -- a-addr     Leave-stack pointer
;   18 USER LP
    defvar LP,2,lp,0,18

;F block-read-vector  -- a-addr
	defvar BLOCK_READ_VECTOR,17,block-read-vector,0,20

;F block-write-vector  -- a-addr
	defvar BLOCK_WRITE_VECTOR,18,block-write-vector,0,22

;F block-buffer-nr  -- a-addr
	defvar BLOCK_BUFFER_NR,15,block-buffer-nr,0,24

;F block-buffer-status  -- a-addr
	defvar BLOCK_BUFFER_STATUS,19,block-buffer-status,0,26

;F scr  -- a-addr
	defvar SCR,3,scr,0,28

;Z s0       -- a-addr     end of parameter stack
    defvar S0,2,s0,0,0x100

;X PAD       -- a-addr    user PAD buffer
;                         = end of hold area!
    defvar PAD,3,pad,0,0x128

;Z l0       -- a-addr     bottom of Leave stack
    defvar L0,2,l0,0,0x180

;Z r0       -- a-addr     end of return stack
    defvar R0,2,r0,0,0x200

;F block-buffer  -- a-addr
	defvar BLOCK_BUFFER,12,block-buffer,0,0x200

;Z uinit    -- addr  initial values for user area
;    head UINIT,5,UINIT,docreate
	dw link
	db 0
link    defl $
	db 5,'uinit'
UINIT:
	call docreate
	dw 0,0,10,0     ; reserved,>IN,BASE,STATE
	dw enddict      ; DP
	dw 0,0          ; SOURCE init'd elsewhere
	dw lastword     ; LATEST
	dw 0            ; HP init'd elsewhere
	dw 0
	dw ROM_BLOCK_READ
	dw ROM_BLOCK_WRITE
	dw 0,0,0

;Z #init    -- n    #bytes of user area init data
    defconst NINIT,5,#init,0,30

; ARITHMETIC OPERATORS ==========================

;C S>D    n -- d          single -> double prec.
;   DUP 0< ;
    defword STOD,3,s>d,0
	dw DUP,ZEROLESS,EXIT

;Z ?NEGATE  n1 n2 -- n3  negate n1 if n2 negative
;   0< IF NEGATE THEN ;        ...a common factor
    defword QNEGATE,7,?negate,0
	dw ZEROLESS,QBRANCH,QNEG1,NEGATE
QNEG1:  dw EXIT

;C ABS     n1 -- +n2     absolute value
;   DUP ?NEGATE ;
    defword ABS,3,abs,0
	dw DUP,QNEGATE,EXIT

;X DNEGATE   d1 -- d2     negate double precision
;   SWAP INVERT SWAP INVERT 1 M+ ;
    defword DNEGATE,7,dnegate,0
	dw SWOP,INVERT,SWOP,INVERT,LIT,1,MPLUS
	dw EXIT

;Z ?DNEGATE  d1 n -- d2   negate d1 if n negative
;   0< IF DNEGATE THEN ;       ...a common factor
    defword QDNEGATE,8,?dnegate,0
	dw ZEROLESS,QBRANCH,DNEG1,DNEGATE
DNEG1:  dw EXIT

;X DABS     d1 -- +d2    absolute value dbl.prec.
;   DUP ?DNEGATE ;
    defword DABS,4,dabs,0
	dw DUP,QDNEGATE,EXIT

;C M*     n1 n2 -- d    signed 16*16->32 multiply
;   2DUP XOR >R        carries sign of the result
;   SWAP ABS SWAP ABS UM*
;   R> ?DNEGATE ;
    defword MSTAR,2,m*,0
	dw TWODUP,XOR,TOR
	dw SWOP,ABS,SWOP,ABS,UMSTAR
	dw RFROM,QDNEGATE,EXIT

;C SM/REM   d1 n1 -- n2 n3   symmetric signed div
;   2DUP XOR >R              sign of quotient
;   OVER >R                  sign of remainder
;   ABS >R DABS R> UM/MOD
;   SWAP R> ?NEGATE
;   SWAP R> ?NEGATE ;
; Ref. dpANS-6 section 3.2.2.1.
    defword SMSLASHREM,6,sm/rem,0
	dw TWODUP,XOR,TOR,OVER,TOR
	dw ABS,TOR,DABS,RFROM,UMSLASHMOD
	dw SWOP,RFROM,QNEGATE,SWOP,RFROM,QNEGATE
	dw EXIT

;C FM/MOD   d1 n1 -- n2 n3   floored signed div'n
;   DUP >R              save divisor
;   SM/REM
;   DUP 0< IF           if quotient negative,
;       SWAP R> +         add divisor to rem'dr
;       SWAP 1-           decrement quotient
;   ELSE R> DROP THEN ;
; Ref. dpANS-6 section 3.2.2.1.
    defword FMSLASHMOD,6,fm/mod,0
	dw DUP,TOR,SMSLASHREM
	dw DUP,ZEROLESS,QBRANCH,FMMOD1
	dw SWOP,RFROM,PLUS,SWOP,ONEMINUS
	dw BRANCH,FMMOD2
FMMOD1: dw RFROM,DROP
FMMOD2: dw EXIT

;C *      n1 n2 -- n3       signed multiply
;   M* DROP ;
    defword STAR,1,*,0
	dw MSTAR,DROP,EXIT

;C /MOD   n1 n2 -- n3 n4    signed divide/rem'dr
;   >R S>D R> FM/MOD ;
    defword SLASHMOD,4,/mod,0
	dw TOR,STOD,RFROM,FMSLASHMOD,EXIT

;C /      n1 n2 -- n3       signed divide
;   /MOD nip ;
    defword SLASH,1,/,0
	dw SLASHMOD,NIP,EXIT

;C MOD    n1 n2 -- n3       signed remainder
;   /MOD DROP ;
    defword MOD,3,mod,0
	dw SLASHMOD,DROP,EXIT

;C */MOD  n1 n2 n3 -- n4 n5    n1*n2/n3, rem&quot
;   >R M* R> FM/MOD ;
    defword SSMOD,5,*/mod,0
	dw TOR,MSTAR,RFROM,FMSLASHMOD,EXIT

;C */     n1 n2 n3 -- n4        n1*n2/n3
;   */MOD nip ;
    defword STARSLASH,2,*/,0
	dw SSMOD,NIP,EXIT

;C MAX    n1 n2 -- n3       signed maximum
;   2DUP < IF SWAP THEN DROP ;
    defword MAX,3,max,0
	dw TWODUP,LESS,QBRANCH,MAX1,SWOP
MAX1:   dw DROP,EXIT

;C MIN    n1 n2 -- n3       signed minimum
;   2DUP > IF SWAP THEN DROP ;
    defword MIN,3,min,0
	dw TWODUP,GREATER,QBRANCH,MIN1,SWOP
MIN1:   dw DROP,EXIT

; DOUBLE OPERATORS ==============================

;C 2@    a-addr -- x1 x2    fetch 2 cells
;   DUP CELL+ @ SWAP @ ;
;   the lower address will appear on top of stack
    defword TWOFETCH,2,2@,0
	dw DUP,CELLPLUS,FETCH,SWOP,FETCH,EXIT

;C 2!    x1 x2 a-addr --    store 2 cells
;   SWAP OVER ! CELL+ ! ;
;   the top of stack is stored at the lower adrs
    defword TWOSTORE,2,2!,0
	dw SWOP,OVER,STORE,CELLPLUS,STORE,EXIT

;C 2DROP  x1 x2 --          drop 2 cells
;   DROP DROP ;
    defword TWODROP,5,2drop,0
	dw DROP,DROP,EXIT

;C 2DUP   x1 x2 -- x1 x2 x1 x2   dup top 2 cells
;   OVER OVER ;
    defword TWODUP,4,2dup,0
	dw OVER,OVER,EXIT

;C 2SWAP  x1 x2 x3 x4 -- x3 x4 x1 x2  per diagram
;   ROT >R ROT R> ;
    defword TWOSWAP,5,2swap,0
	dw ROT,TOR,ROT,RFROM,EXIT

;C 2OVER  x1 x2 x3 x4 -- x1 x2 x3 x4 x1 x2
;   >R >R 2DUP R> R> 2SWAP ;
    defword TWOOVER,5,2over,0
	dw TOR,TOR,TWODUP,RFROM,RFROM
	dw TWOSWAP,EXIT

; INPUT/OUTPUT ==================================

;C COUNT   c-addr1 -- c-addr2 u  counted->adr/len
;   DUP CHAR+ SWAP C@ ;
    defword COUNT,5,count,0
	dw DUP,CHARPLUS,SWOP,CFETCH,EXIT

;C CR      --               output newline
;   0A EMIT ;
    defword CR,2,cr,0
	dw LIT,0x0a,EMIT,EXIT

;C SPACE   --               output a space
;   BL EMIT ;
    defword SPACE,5,space,0
	dw BL,EMIT,EXIT

;C SPACES   n --            output n spaces
;   BEGIN DUP WHILE SPACE 1- REPEAT DROP ;
    defword SPACES,6,spaces,0
SPCS1:  dw DUP,QBRANCH,SPCS2
	dw SPACE,ONEMINUS,BRANCH,SPCS1
SPCS2:  dw DROP,EXIT

;Z umin     u1 u2 -- u      unsigned minimum
;   2DUP U> IF SWAP THEN DROP ;
    defword UMIN,4,umin,0
	dw TWODUP,UGREATER,QBRANCH,UMIN1,SWOP
UMIN1:  dw DROP,EXIT

;Z umax    u1 u2 -- u       unsigned maximum
;   2DUP U< IF SWAP THEN DROP ;
    defword UMAX,4,umax,0
	dw TWODUP,ULESS,QBRANCH,UMAX1,SWOP
UMAX1:  dw DROP,EXIT

;C ACCEPT  c-addr +n -- +n'  get line from term'l
;   OVER + 1- OVER      -- sa ea a
;   BEGIN KEY           -- sa ea a c
;   DUP 0A <> WHILE
;       DUP EMIT        -- sa ea a c
;       DUP 8 = IF  DROP 1-    >R OVER R> UMAX
;             ELSE  OVER C! 1+ OVER UMIN
;       THEN            -- sa ea a
;   REPEAT              -- sa ea a c
;   DROP NIP SWAP - ;
    defword ACCEPT,6,accept,0
	dw OVER,PLUS,ONEMINUS,OVER
ACC1:   dw KEY,DUP,LIT,0AH,NOTEQUAL,QBRANCH,ACC5
	dw DUP,EMIT,DUP,LIT,8,EQUAL,QBRANCH,ACC3
	dw DROP,ONEMINUS,TOR,OVER,RFROM,UMAX
	dw BRANCH,ACC4
ACC3:   dw OVER,CSTORE,ONEPLUS,OVER,UMIN
ACC4:   dw BRANCH,ACC1
ACC5:   dw DROP,NIP,SWOP,MINUS,EXIT

;C TYPE    c-addr +n --     type line to term'l
;   ?DUP IF
;     OVER + SWAP DO I C@ EMIT LOOP
;   ELSE DROP THEN ;
    defword TYPE,4,type,0
	dw QDUP,QBRANCH,TYP4
	dw OVER,PLUS,SWOP,XDO
TYP3:   dw II,CFETCH,EMIT,XLOOP,TYP3
	dw BRANCH,TYP5
TYP4:   dw DROP
TYP5:   dw EXIT

;Z (S")     -- c-addr u   run-time code for S"
;   R> COUNT 2DUP + ALIGNED >R  ;
    defword XSQUOTE,4,<(s")>,0
	dw RFROM,COUNT,TWODUP,PLUS,ALIGNED,TOR
	dw EXIT

;C S"       --         compile in-line string
;   COMPILE (S")  [ HEX ]
;   22 WORD C@ 1+ ALIGNED ALLOT ; IMMEDIATE
    defword SQUOTE,2,<s">,F_IMMED
	dw LIT,XSQUOTE,COMMAXT
	dw LIT,22H,WORD,CFETCH,ONEPLUS
	dw ALIGNED,ALLOT,EXIT

;C ."       --         compile string to print
;   POSTPONE S"  POSTPONE TYPE ; IMMEDIATE
    defword DOTQUOTE,2,<.">,F_IMMED
	dw SQUOTE
	dw LIT,TYPE,COMMAXT
	dw EXIT

; NUMERIC OUTPUT ================================
; Numeric conversion is done l.s.digit first, so
; the output buffer is built backwards in memory.

; Some double-precision arithmetic operators are
; needed to implement ANSI numeric conversion.

;Z UD/MOD   ud1 u2 -- u3 ud4   32/16->32 divide
;   >R 0 R@ UM/MOD  ROT ROT R> UM/MOD ROT ;
    defword UDSLASHMOD,6,ud/mod,0
	dw TOR,LIT,0,RFETCH,UMSLASHMOD,ROT,ROT
	dw RFROM,UMSLASHMOD,ROT,EXIT

;Z UD*      ud1 d2 -- ud3      32*16->32 multiply
;   DUP >R UM* DROP  SWAP R> UM* ROT + ;
    defword UDSTAR,3,ud*,0
	dw DUP,TOR,UMSTAR,DROP
	dw SWOP,RFROM,UMSTAR,ROT,PLUS,EXIT

;C HOLD  char --        add char to output string
;   -1 HP +!  HP @ C! ;
    defword HOLD,4,hold,0
	dw LIT,-1,HP,PLUSSTORE
	dw HP,FETCH,CSTORE,EXIT

;C <#    --             begin numeric conversion
;   PAD HP ! ;          (initialize Hold Pointer)
    defword LESSNUM,2,<<#>,0
	dw PAD,HP,STORE,EXIT

;Z >digit   n -- c      convert to 0..9A..Z
;   [ HEX ] DUP 9 > 7 AND + 30 + ;
    defword TODIGIT,6,>digit,0
	dw DUP,LIT,9,GREATER,LIT,7,AND,PLUS
	dw LIT,30H,PLUS,EXIT

;C #     ud1 -- ud2     convert 1 digit of output
;   BASE @ UD/MOD ROT >digit HOLD ;
    defword NUM,1,#,0
	dw BASE,FETCH,UDSLASHMOD,ROT,TODIGIT
	dw HOLD,EXIT

;C #S    ud1 -- ud2     convert remaining digits
;   BEGIN # 2DUP OR 0= UNTIL ;
    defword NUMS,2,#s,0
NUMS1:  dw NUM,TWODUP,OR,ZEROEQUAL,QBRANCH,NUMS1
	dw EXIT

;C #>    ud1 -- c-addr u    end conv., get string
;   2DROP HP @ PAD OVER - ;
    defword NUMGREATER,2,#>,0
	dw TWODROP,HP,FETCH,PAD,OVER,MINUS,EXIT

;C SIGN  n --           add minus sign if n<0
;   0< IF 2D HOLD THEN ;
    defword SIGN,4,sign,0
	dw ZEROLESS,QBRANCH,SIGN1,LIT,2DH,HOLD
SIGN1:  dw EXIT

;C U.    u --           display u unsigned
;   <# 0 #S #> TYPE SPACE ;
    defword UDOT,2,u.,0
	dw LESSNUM,LIT,0,NUMS,NUMGREATER,TYPE
	dw SPACE,EXIT

;C .     n --           display n signed
;   <# DUP ABS 0 #S ROT SIGN #> TYPE SPACE ;
    defword DOT,1,<.>,0
	dw LESSNUM,DUP,ABS,LIT,0,NUMS
	dw ROT,SIGN,NUMGREATER,TYPE,SPACE,EXIT

;C DECIMAL  --      set number base to decimal
;   10 BASE ! ;
    defword DECIMAL,7,decimal,0
	dw LIT,10,BASE,STORE,EXIT

;X HEX     --       set number base to hex
;   16 BASE ! ;
    defword HEX,3,hex,0
	dw LIT,16,BASE,STORE,EXIT

; DICTIONARY MANAGEMENT =========================

;C HERE    -- addr      returns dictionary ptr
;   DP @ ;
    defword HERE,4,here,0
	dw DP,FETCH,EXIT

;C ALLOT   n --         allocate n bytes in dict
;   DP +! ;
    defword ALLOT,5,allot,0
	dw DP,PLUSSTORE,EXIT

; Note: , and C, are only valid for combined
; Code and Data spaces.

;C ,    x --           append cell to dict
;   HERE ! 1 CELLS ALLOT ;
    defword COMMA,1,<,>,0
	dw HERE,STORE,LIT,1,CELLS,ALLOT,EXIT

;C C,   char --        append char to dict
;   HERE C! 1 CHARS ALLOT ;
    defword CCOMMA,2,<c,>,0
	dw HERE,CSTORE,LIT,1,CHARS,ALLOT,EXIT

; INTERPRETER ===================================
; Note that NFA>LFA, NFA>CFA, IMMED?, and FIND
; are dependent on the structure of the Forth
; header.  This may be common across many CPUs,
; or it may be different.

;C SOURCE   -- adr n    current input buffer
;   'SOURCE 2@ ;        length is at lower adrs
    defword SOURCE,6,source,0
	dw TICKSOURCE,TWOFETCH,EXIT

;X /STRING  a u n -- a+n u-n   trim string
;   ROT OVER + ROT ROT - ;
    defword SLASHSTRING,7,/string,0
	dw ROT,OVER,PLUS,ROT,ROT,MINUS,EXIT

;Z >counted  src n dst --     copy to counted str
;   2DUP C! CHAR+ SWAP CMOVE ;
    defword TOCOUNTED,8,>counted,0
	dw TWODUP,CSTORE,CHARPLUS,SWOP,CMOVE,EXIT

;C WORD   char -- c-addr n   word delim'd by char
;   DUP  SOURCE >IN @ /STRING   -- c c adr n
;   DUP >R   ROT SKIP           -- c adr' n'
;   OVER >R  ROT SCAN           -- adr" n"
;   DUP IF CHAR- THEN        skip trailing delim.
;   R> R> ROT -   >IN +!        update >IN offset
;   TUCK -                      -- adr' N
;   HERE >counted               --
;   HERE                        -- a
;   BL OVER COUNT + C! ;    append trailing blank
    defword WORD,4,word,0
	dw DUP,SOURCE,TOIN,FETCH
	dw SLASHSTRING
	dw DUP,TOR,ROT,SKIP
	dw OVER,TOR,ROT,SCAN
	dw DUP,QBRANCH,WORD1,ONEMINUS  ; char-
WORD1:  dw RFROM,RFROM,ROT,MINUS,TOIN,PLUSSTORE
	dw TUCK,MINUS
	dw HERE,TOCOUNTED,HERE
	dw BL,OVER,COUNT,PLUS,CSTORE,EXIT

;Z NFA>LFA   nfa -- lfa    name adr -> link field
;   3 - ;
    defword NFATOLFA,7,nfa>lfa,0
	dw LIT,3,MINUS,EXIT

;Z NFA>CFA   nfa -- cfa    name adr -> code field
;   COUNT 7F AND + ;       mask off 'smudge' bit
    defword NFATOCFA,7,nfa>cfa,0
	dw COUNT,LIT,07FH,AND,PLUS,EXIT

;Z IMMED?    nfa -- f      fetch immediate flag
;   1- C@ ;                     nonzero if immed
    defword IMMEDQ,6,immed?,0
	dw ONEMINUS,CFETCH,EXIT

;C FIND   c-addr -- c-addr 0   if not found
;C                  xt  1      if immediate
;C                  xt -1      if "normal"
;   LATEST @ BEGIN             -- a nfa
;       2DUP OVER C@ CHAR+     -- a nfa a nfa n+1
;       S=                     -- a nfa f
;       DUP IF
;           DROP
;           NFA>LFA @ DUP      -- a link link
;       THEN
;   0= UNTIL                   -- a nfa  OR  a 0
;   DUP IF
;       NIP DUP NFA>CFA        -- nfa xt
;       SWAP IMMED?            -- xt iflag
;       0= 1 OR                -- xt 1/-1
;   THEN ;
    defword FIND,4,find,0
	dw LATEST,FETCH
FIND1:  dw TWODUP,OVER,CFETCH,CHARPLUS
	dw SEQUAL,DUP,QBRANCH,FIND2
	dw DROP,NFATOLFA,FETCH,DUP
FIND2:  dw ZEROEQUAL,QBRANCH,FIND1
	dw DUP,QBRANCH,FIND3
	dw NIP,DUP,NFATOCFA
	dw SWOP,IMMEDQ,ZEROEQUAL,LIT,1,OR
FIND3:  dw EXIT

;C LITERAL  x --        append numeric literal
;   STATE @ IF ['] LIT ,XT , THEN ; IMMEDIATE
; This tests STATE so that it can also be used
; interpretively.  (ANSI doesn't require this.)
    defword LITERAL,7,literal,F_IMMED
	dw STATE,FETCH,QBRANCH,LITER1
	dw LIT,LIT,COMMAXT,COMMA
LITER1: dw EXIT

;Z DIGIT?   c -- n -1   if c is a valid digit
;Z            -- x  0   otherwise
;   [ HEX ] DUP 39 > 100 AND +     silly looking
;   DUP 140 > 107 AND -   30 -     but it works!
;   DUP BASE @ U< ;
    defword DIGITQ,6,digit?,0
	dw DUP,LIT,39H,GREATER,LIT,100H,AND,PLUS
	dw DUP,LIT,140H,GREATER,LIT,107H,AND
	dw MINUS,LIT,30H,MINUS
	dw DUP,BASE,FETCH,ULESS,EXIT

;Z ?SIGN   adr n -- adr' n' f  get optional sign
;Z  advance adr/n if sign; return NZ if negative
;   OVER C@                 -- adr n c
;   2C - DUP ABS 1 = AND    -- +=-1, -=+1, else 0
;   DUP IF 1+               -- +=0, -=+2
;       >R 1 /STRING R>     -- adr' n' f
;   THEN ;
    defword QSIGN,5,?sign,0
	dw OVER,CFETCH,LIT,2CH,MINUS,DUP,ABS
	dw LIT,1,EQUAL,AND,DUP,QBRANCH,QSIGN1
	dw ONEPLUS,TOR,LIT,1,SLASHSTRING,RFROM
QSIGN1: dw EXIT

;C >NUMBER  ud adr u -- ud' adr' u'
;C                      convert string to number
;   BEGIN
;   DUP WHILE
;       OVER C@ DIGIT?
;       0= IF DROP EXIT THEN
;       >R 2SWAP BASE @ UD*
;       R> M+ 2SWAP
;       1 /STRING
;   REPEAT ;
    defword TONUMBER,7,>number,0
TONUM1: dw DUP,QBRANCH,TONUM3
	dw OVER,CFETCH,DIGITQ
	dw ZEROEQUAL,QBRANCH,TONUM2,DROP,EXIT
TONUM2: dw TOR,TWOSWAP,BASE,FETCH,UDSTAR
	dw RFROM,MPLUS,TWOSWAP
	dw LIT,1,SLASHSTRING,BRANCH,TONUM1
TONUM3: dw EXIT

;Z ?NUMBER  c-addr -- n -1      string->number
;Z                 -- c-addr 0  if convert error
;   DUP  0 0 ROT COUNT      -- ca ud adr n
;   ?SIGN >R  >NUMBER       -- ca ud adr' n'
;   IF   R> 2DROP 2DROP 0   -- ca 0   (error)
;   ELSE 2DROP NIP R>
;       IF NEGATE THEN  -1  -- n -1   (ok)
;   THEN ;
    defword QNUMBER,7,?number,0
	dw DUP,LIT,0,DUP,ROT,COUNT
	dw QSIGN,TOR,TONUMBER,QBRANCH,QNUM1
	dw RFROM,TWODROP,TWODROP,LIT,0
	dw BRANCH,QNUM3
QNUM1:  dw TWODROP,NIP,RFROM,QBRANCH,QNUM2,NEGATE
QNUM2:  dw LIT,-1
QNUM3:  dw EXIT

;Z INTERPRET    i*x c-addr u -- j*x
;Z                      interpret given buffer
; This is a common factor of EVALUATE and QUIT.
; ref. dpANS-6, 3.4 The Forth Text Interpreter
;   'SOURCE 2!  0 >IN !
;   BEGIN
;   BL WORD DUP C@ WHILE        -- textadr
;       FIND                    -- a 0/1/-1
;       ?DUP IF                 -- xt 1/-1
;           1+ STATE @ 0= OR    immed or interp?
;           IF EXECUTE ELSE ,XT THEN
;       ELSE                    -- textadr
;           ?NUMBER
;           IF POSTPONE LITERAL     converted ok
;           ELSE COUNT TYPE 3F EMIT CR ABORT  err
;           THEN
;       THEN
;   REPEAT DROP ;
    defword INTERPRET,9,interpret,0
	dw TICKSOURCE,TWOSTORE,LIT,0,TOIN,STORE
INTER1: dw BL,WORD,DUP,CFETCH,QBRANCH,INTER9
	dw FIND,QDUP,QBRANCH,INTER4
	dw ONEPLUS,STATE,FETCH,ZEROEQUAL,OR
	dw QBRANCH,INTER2
	dw EXECUTE,BRANCH,INTER3
INTER2: dw COMMAXT
INTER3: dw BRANCH,INTER8
INTER4: dw QNUMBER,QBRANCH,INTER5
	dw LITERAL,BRANCH,INTER6
INTER5: dw COUNT,TYPE,LIT,3FH,EMIT,CR,ABORT
INTER6:
INTER8: dw BRANCH,INTER1
INTER9: dw DROP,EXIT

;C EVALUATE  i*x c-addr u -- j*x  interprt string
;   'SOURCE 2@ >R >R  >IN @ >R
;   INTERPRET
;   R> >IN !  R> R> 'SOURCE 2! ;
    defword EVALUATE,8,evaluate,0
	dw TICKSOURCE,TWOFETCH,TOR,TOR
	dw TOIN,FETCH,TOR,INTERPRET
	dw RFROM,TOIN,STORE,RFROM,RFROM
	dw TICKSOURCE,TWOSTORE,EXIT

;C QUIT     --    R: i*x --    interpret from kbd
;   L0 LP !  R0 RP!   0 STATE !
;   BEGIN
;       TIB DUP TIBSIZE ACCEPT  SPACE
;       INTERPRET
;       STATE @ 0= IF CR ." OK" THEN
;   AGAIN ;
    defword QUIT,4,quit,0
	dw L0,LP,STORE
	dw R0,RPSTORE,LIT,0,STATE,STORE
QUIT1:  dw TIB,DUP,TIBSIZE,ACCEPT,SPACE
	dw INTERPRET
	dw STATE,FETCH,ZEROEQUAL,QBRANCH,QUIT2
	dw XSQUOTE
	db 3,' ok'
	dw TYPE,CR
QUIT2:  dw BRANCH,QUIT1

;C ABORT    i*x --   R: j*x --   clear stk & QUIT
;   S0 SP!  QUIT ;
    defword ABORT,5,abort,0
	dw S0,SPSTORE,QUIT   ; QUIT never returns

;Z ?ABORT   f c-addr u --      abort & print msg
;   ROT IF TYPE ABORT THEN 2DROP ;
    defword QABORT,6,?abort,0
	dw ROT,QBRANCH,QABO1,TYPE,ABORT
QABO1:  dw TWODROP,EXIT

;C ABORT"  i*x 0  -- i*x   R: j*x -- j*x  x1=0
;C         i*x x1 --       R: j*x --      x1<>0
;   POSTPONE S" POSTPONE ?ABORT ; IMMEDIATE
    defword ABORTQUOTE,6,<abort">,F_IMMED
	dw SQUOTE
	dw LIT,QABORT,COMMAXT
	dw EXIT

;C '    -- xt           find word in dictionary
;   BL WORD FIND
;   0= ABORT" ?" ;
;    defword TICK,1,',0
	dw link                 ; must expand
	db 0                    ; manually
link    defl $                  ; because of
	db 1,0x27                ; tick character
TICK:   call docolon
	dw BL,WORD,FIND,ZEROEQUAL,XSQUOTE
	db 1,'?'
	dw QABORT,EXIT

;C CHAR   -- char           parse ASCII character
;   BL WORD 1+ C@ ;
    defword CHAR,4,char,0
	dw BL,WORD,ONEPLUS,CFETCH,EXIT

;C [CHAR]   --          compile character literal
;   CHAR  ['] LIT ,XT  , ; IMMEDIATE
    defword BRACCHAR,6,[char],F_IMMED
	dw CHAR
	dw LIT,LIT,COMMAXT
	dw COMMA,EXIT

;C (    --                     skip input until )
;   [ HEX ] 29 WORD DROP ; IMMEDIATE
    defword PAREN,1,(,F_IMMED
	dw LIT,29H,WORD,DROP,EXIT

; COMPILER ======================================

;C CREATE   --      create an empty definition
;   LATEST @ , 0 C,         link & immed field
;   HERE LATEST !           new "latest" link
;   BL WORD C@ 1+ ALLOT         name field
;   docreate ,CF                code field
    defword CREATE,6,create,0
	dw LATEST,FETCH,COMMA,LIT,0,CCOMMA
	dw HERE,LATEST,STORE
	dw BL,WORD,CFETCH,ONEPLUS,ALLOT
	dw LIT,docreate,COMMACF,EXIT
	
;Z (DOES>)  --      run-time action of DOES>
;   R>              adrs of headless DOES> def'n
;   LATEST @ NFA>CFA    code field to fix up
;   !CF ;
    defword XDOES,7,(does>),0
	dw RFROM,LATEST,FETCH,NFATOCFA,STORECF
	dw EXIT

;C DOES>    --      change action of latest def'n
;   COMPILE (DOES>)
;   dodoes ,CF ; IMMEDIATE
    defword DOES,5,does>,F_IMMED
	dw LIT,XDOES,COMMAXT
	dw LIT,dodoes,COMMACF,EXIT

;C RECURSE  --      recurse current definition
;   LATEST @ NFA>CFA ,XT ; IMMEDIATE
    defword RECURSE,7,recurse,F_IMMED
	dw LATEST,FETCH,NFATOCFA,COMMAXT,EXIT

;C [        --      enter interpretive state
;   0 STATE ! ; IMMEDIATE
    defword LEFTBRACKET,1,[,F_IMMED
	dw LIT,0,STATE,STORE,EXIT

;C ]        --      enter compiling state
;   -1 STATE ! ;
    defword RIGHTBRACKET,1,],0
	dw LIT,-1,STATE,STORE,EXIT

;Z HIDE     --      "hide" latest definition
;   LATEST @ DUP C@ 80 OR SWAP C! ;
    defword HIDE,4,hide,0
	dw LATEST,FETCH,DUP,CFETCH,LIT,80H,OR
	dw SWOP,CSTORE,EXIT

;Z REVEAL   --      "reveal" latest definition
;   LATEST @ DUP C@ 7F AND SWAP C! ;
    defword REVEAL,6,reveal,0
	dw LATEST,FETCH,DUP,CFETCH,LIT,7FH,AND
	dw SWOP,CSTORE,EXIT

;C IMMEDIATE   --   make last def'n immediate
;   1 LATEST @ 1- C! ;   set immediate flag
    defword IMMEDIATE,9,immediate,0
	dw LIT,1,LATEST,FETCH,ONEMINUS,CSTORE
	dw EXIT

;C :        --      begin a colon definition
;   CREATE HIDE ] !COLON ;
    defcode COLON,1,:,0
	CALL docolon    ; code fwd ref explicitly
	dw CREATE,HIDE,RIGHTBRACKET,STORCOLON
	dw EXIT

;C ;
;   REVEAL  ,EXIT
;   POSTPONE [  ; IMMEDIATE
    defword SEMICOLON,1,<;>,F_IMMED
	dw REVEAL,CEXIT
	dw LEFTBRACKET,EXIT

;C [']  --         find word & compile as literal
;   '  ['] LIT ,XT  , ; IMMEDIATE
; When encountered in a colon definition, the
; phrase  ['] xxx  will cause   LIT,xxt  to be
; compiled into the colon definition (where
; (where xxt is the execution token of word xxx).
; When the colon definition executes, xxt will
; be put on the stack.  (All xt's are one cell.)
;    defword BRACTICK,3,['],F_IMMED
	dw link                 ; must expand
	db 1                    ; manually
link    defl $                  ; because of
	db 3,0x5B,0x27,0x5D        ; tick character
BRACTICK: call docolon
	dw TICK               ; get xt of 'xxx'
	dw LIT,LIT,COMMAXT    ; append LIT action
	dw COMMA,EXIT         ; append xt literal

;C POSTPONE  --   postpone compile action of word
;   BL WORD FIND
;   DUP 0= ABORT" ?"
;   0< IF   -- xt  non immed: add code to current
;                  def'n to compile xt later.
;       ['] LIT ,XT  ,      add "LIT,xt,COMMAXT"
;       ['] ,XT ,XT         to current definition
;   ELSE  ,XT      immed: compile into cur. def'n
;   THEN ; IMMEDIATE
    defword POSTPONE,8,postpone,F_IMMED
	dw BL,WORD,FIND,DUP,ZEROEQUAL,XSQUOTE
	db 1,'?'
	dw QABORT,ZEROLESS,QBRANCH,POST1
	dw LIT,LIT,COMMAXT,COMMA
	dw LIT,COMMAXT,COMMAXT,BRANCH,POST2
POST1:  dw COMMAXT
POST2:  dw EXIT

;Z COMPILE   --   append inline execution token
;   R> DUP CELL+ >R @ ,XT ;
; The phrase ['] xxx ,XT appears so often that
; this word was created to combine the actions
; of LIT and ,XT.  It takes an inline literal
; execution token and appends it to the dict.
;    defword COMPILE,7,compile,0
;        dw RFROM,DUP,CELLPLUS,TOR
;        dw FETCH,COMMAXT,EXIT
; N.B.: not used in the current implementation

; CONTROL STRUCTURES ============================

;C IF       -- adrs    conditional forward BRANCH
;   ['] QBRANCH ,BRANCH  HERE DUP ,DEST ;
;   IMMEDIATE
    defword IF,2,if,F_IMMED
	dw LIT,QBRANCH,COMMABRANCH
	dw HERE,DUP,COMMADEST,EXIT

;C THEN     adrs --        resolve forward BRANCH
;   HERE SWAP !DEST ; IMMEDIATE
    defword THEN,4,then,F_IMMED
	dw HERE,SWOP,STOREDEST,EXIT

;C ELSE     adrs1 -- adrs2    BRANCH for IF..ELSE
;   ['] BRANCH ,BRANCH  HERE DUP ,DEST
;   SWAP  POSTPONE THEN ; IMMEDIATE
    defword ELSE,4,else,F_IMMED
	dw LIT,BRANCH,COMMABRANCH
	dw HERE,DUP,COMMADEST
	dw SWOP,THEN,EXIT

;C BEGIN    -- adrs        target for bwd. BRANCH
;   HERE ; IMMEDIATE
    defcode BEGIN,5,begin,F_IMMED
	jp HERE

;C UNTIL    adrs --   conditional backward BRANCH
;   ['] QBRANCH ,BRANCH  ,DEST ; IMMEDIATE
;   conditional backward BRANCH
    defword UNTIL,5,until,F_IMMED
	dw LIT,QBRANCH,COMMABRANCH
	dw COMMADEST,EXIT

;X AGAIN    adrs --      uncond'l backward BRANCH
;   ['] BRANCH ,BRANCH  ,DEST ; IMMEDIATE
;   unconditional backward BRANCH
    defword AGAIN,5,again,F_IMMED
	dw LIT,BRANCH,COMMABRANCH
	dw COMMADEST,EXIT

;C WHILE    -- adrs         BRANCH for WHILE loop
;   POSTPONE IF ; IMMEDIATE
    defcode WHILE,5,while,F_IMMED
	jp IF

;C REPEAT   adrs1 adrs2 --     resolve WHILE loop
;   SWAP POSTPONE AGAIN POSTPONE THEN ; IMMEDIATE
    defword REPEAT,6,repeat,F_IMMED
	dw SWOP,AGAIN,THEN,EXIT

;Z >L   x --   L: -- x        move to leave stack
;   CELL LP +!  LP @ ! ;      (L stack grows up)
    defword TOL,2,>l,0
	dw CELL,LP,PLUSSTORE,LP,FETCH,STORE,EXIT

;Z L>   -- x   L: x --      move from leave stack
;   LP @ @  CELL NEGATE LP +! ;
    defword LFROM,2,l>,0
	dw LP,FETCH,FETCH
	dw CELL,NEGATE,LP,PLUSSTORE,EXIT

;C DO       -- adrs   L: -- 0
;   ['] xdo ,XT   HERE     target for bwd BRANCH
;   0 >L ; IMMEDIATE           marker for LEAVEs
    defword DO,2,do,F_IMMED
	dw LIT,XDO,COMMAXT,HERE
	dw LIT,0,TOL,EXIT

;Z ENDLOOP   adrs xt --   L: 0 a1 a2 .. aN --
;   ,BRANCH  ,DEST                backward loop
;   BEGIN L> ?DUP WHILE POSTPONE THEN REPEAT ;
;                                 resolve LEAVEs
; This is a common factor of LOOP and +LOOP.
    defword ENDLOOP,7,endloop,0
	dw COMMABRANCH,COMMADEST
LOOP1:  dw LFROM,QDUP,QBRANCH,LOOP2
	dw THEN,BRANCH,LOOP1
LOOP2:  dw EXIT

;C LOOP    adrs --   L: 0 a1 a2 .. aN --
;   ['] xloop ENDLOOP ;  IMMEDIATE
    defword LOOP,4,loop,F_IMMED
	dw LIT,XLOOP,ENDLOOP,EXIT

;C +LOOP   adrs --   L: 0 a1 a2 .. aN --
;   ['] xplusloop ENDLOOP ;  IMMEDIATE
    defword PLUSLOOP,5,+loop,F_IMMED
	dw LIT,XPLUSLOOP,ENDLOOP,EXIT

;C LEAVE    --    L: -- adrs
;   ['] UNLOOP ,XT
;   ['] BRANCH ,BRANCH   HERE DUP ,DEST  >L
;   ; IMMEDIATE      unconditional forward BRANCH
    defword LEAVE,5,leave,F_IMMED
	dw LIT,UNLOOP,COMMAXT
	dw LIT,BRANCH,COMMABRANCH
	dw HERE,DUP,COMMADEST,TOL,EXIT

; OTHER OPERATIONS ==============================

;X WITHIN   n1|u1 n2|u2 n3|u3 -- f   n2<=n1<n3?
;  OVER - >R - R> U< ;          per ANS document
    defword WITHIN,6,within,0
	dw OVER,MINUS,TOR,MINUS,RFROM,ULESS,EXIT

;C MOVE    addr1 addr2 u --     smart move
;             VERSION FOR 1 ADDRESS UNIT = 1 CHAR
;  >R 2DUP SWAP DUP R@ +     -- ... dst src src+n
;  WITHIN IF  R> CMOVE>        src <= dst < src+n
;       ELSE  R> CMOVE  THEN ;          otherwise
    defword MOVE,4,move,0
	dw TOR,TWODUP,SWOP,DUP,RFETCH,PLUS
	dw WITHIN,QBRANCH,MOVE1
	dw RFROM,CMOVEUP,BRANCH,MOVE2
MOVE1:  dw RFROM,CMOVE
MOVE2:  dw EXIT

;C DEPTH    -- +n        number of items on stack
;   SP@ S0 SWAP - 2/ ;   16-BIT VERSION!
    defword DEPTH,5,depth,0
	dw SPFETCH,S0,SWOP,MINUS,TWOSLASH,EXIT

;C ENVIRONMENT?  c-addr u -- false   system query
;                         -- i*x true
;   2DROP 0 ;       the minimal definition!
    defword ENVIRONMENTQ,12,environment?,0
	dw TWODROP,LIT,0,EXIT

; UTILITY WORDS AND STARTUP =====================

;X WORDS    --          list all words in dict.
;   LATEST @ BEGIN
;       DUP COUNT TYPE SPACE
;       NFA>LFA @
;   DUP 0= UNTIL
;   DROP ;
    defword WORDS,5,words,0
	dw LATEST,FETCH
WDS1:   dw DUP,COUNT,TYPE,SPACE,NFATOLFA,FETCH
	dw DUP,ZEROEQUAL,QBRANCH,WDS1
	dw DROP,EXIT

;X .S      --           print stack contents
;   SP@ S0 - IF
;       SP@ S0 2 - DO I @ U. -2 +LOOP
;   THEN ;
    defword DOTS,2,<.s>,0
	dw SPFETCH,S0,MINUS,QBRANCH,DOTS2
	dw SPFETCH,S0,LIT,2,MINUS,XDO
DOTS1:  dw II,FETCH,UDOT,LIT,-2,XPLUSLOOP,DOTS1
DOTS2:  dw EXIT

;Z COLD     --      cold start Forth system
;   UINIT U0 #INIT CMOVE      init user area
;   ." Z80 CamelForth etc."
;   ABORT ;
    defword COLD,4,cold,0
	dw UINIT,U0,NINIT,CMOVE
	dw XSQUOTE
	db 34,'Z80 CamelForth v1.01  25 Jan 1995'
	db 0x0a
	dw TYPE,XSQUOTE
	db 57,'RC2014 Mods from Robert Liesenfield and Hans Van Slooten'
	db 0x0a
	dw TYPE,ABORT       ; ABORT never returns

; --- Block words ---

romdiskReadStart:
	; hl: source addr
	; de: dest addr
	ld a, 8 ; TODO preserve RAM bank
	out (0x02), a
	ld bc, 1024
	ldir
	xor a
	out (0x02), a
	ret
romdiskReadEnd:

;F ROM-BLOCK-READ  block# addr --
	defcode ROM_BLOCK_READ,14,rom-block-read,0
	pop hl ;block#
	ld h, l ;multiply by 256
	ld l, 0
	sla h
	sla h ;hl: rom address
	push de
	ld d, b
	ld e, c
	call romdiskRead
	pop de
	pop bc
	next

;F ROM-BLOCK-WRITE  block# addr --
	defcode ROM_BLOCK_WRITE,15,rom-block-write,0
	pop hl ;block#
	ld h, l ;multiply by 256
	ld l, 0
	sla h
	sla h ;hl: rom address
	push de
	ld d, b
	ld e, c
	ex de, hl
	call romdiskRead
	pop de
	pop bc
	next

;F romdisk  ( -- read-vector write-vector )
; ['] rom-block-read ['] rom-block-write ;
	defword ROMDISK,7,romdisk,0
	dw LIT, ROM_BLOCK_READ, LIT, ROM_BLOCK_WRITE, EXIT

;Z CELL     -- n                 size of one cell
    defconst BLOCK_EMPTY,11,block-empty,0,0
    defconst BLOCK_CLEAN,11,block-clean,0,1
    defconst BLOCK_DIRTY,11,block-dirty,0,2


;F block-read ( block# buf-addr -- )
; block-read-vector @ execute ;
	defword BLOCK_READ,10,block-read,0
	dw BLOCK_READ_VECTOR, FETCH, EXECUTE, EXIT

;F block-write ( block# buf-addr -- )
; block-write-vector @ execute ;
	defword BLOCK_WRITE,11,block-write,0
	dw BLOCK_WRITE_VECTOR, FETCH, EXECUTE, EXIT

;F use ( -- )
;    bl word count evaluate
;    block-write-vector !
;    block-read-vector ! ;
	defword USE,3,use,0
	dw BL, WORD, COUNT, EVALUATE
	dw BLOCK_WRITE_VECTOR, STORE
	dw BLOCK_READ_VECTOR, STORE


; save-buffers ( -- )
;    block-buffer-status @ dirty = if
;        ( write to disk )
;        block-buffer-nr @ block-buffer block-write
;    then
;    clean block-buffer-status ! ;
	defword SAVE_BUFFERS,12,save-buffers,0
	dw BLOCK_BUFFER_STATUS,FETCH,BLOCK_DIRTY,EQUAL,QBRANCH,SAVE_BUFFERS1
	dw BLOCK_BUFFER_NR,FETCH,BLOCK_BUFFER,BLOCK_WRITE
SAVE_BUFFERS1:
	dw BLOCK_CLEAN,BLOCK_BUFFER_STATUS,STORE,EXIT

; buffer ( block# -- addr )
;    save-buffers
;    block-buffer-nr !
;    block-buffer ;
	defword BUFFER,6,buffer,0
	dw SAVE_BUFFERS,BLOCK_BUFFER_NR,STORE,BLOCK_BUFFER,EXIT


; block ( block# -- addr )
;    ( check if block is already in memory )
;    dup block-buffer-nr @ = block-buffer-status @ empty <> and if
;        drop
;    else
;        dup buffer block-read
;        clean block-buffer-status !
;    then block-buffer ;
	defword BLOCK,5,block,0
	dw DUP,BLOCK_BUFFER_NR,FETCH,EQUAL,BLOCK_BUFFER_STATUS,FETCH
	dw BLOCK_EMPTY,NOTEQUAL,AND,QBRANCH,BLOCK1,DROP,BRANCH,BLOCK2
BLOCK1:
	dw DUP,BUFFER,BLOCK_READ,BLOCK_CLEAN,BLOCK_BUFFER_STATUS,STORE
BLOCK2: dw BLOCK_BUFFER,EXIT


; update ( -- ) dirty block-buffer-status ! ;
	defword UPDATE,6,update,0
	dw BLOCK_DIRTY,BLOCK_BUFFER_STATUS,STORE,EXIT

; flush ( -- ) save-buffers empty block-buffer-status ! ;
	defword FLUSH,5,flush,0
	dw SAVE_BUFFERS,BLOCK_EMPTY,BLOCK_BUFFER_STATUS,STORE,EXIT

; empty-buffers ( -- ) empty block-buffer-status ! ;
	defword EMPTY_BUFFERS,13,empty-buffers,0
	dw BLOCK_EMPTY,BLOCK_BUFFER_STATUS,STORE,EXIT

; load ( block# -- ) block 1024 evaluate ;
	defword LOAD,4,load,0
	dw BLOCK,LIT,1024,EVALUATE,EXIT




lastword equ link   ; nfa of last word in dict.
