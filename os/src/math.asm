;; Contains advanced math routines
;;
;; Based on: <http://www.ticalc.org/pub/83/asm/source/routines/math32.inc>
.list


add32:
;; Add two 32-bit numbers
;;
;; Input:
;; : (hl), (de) - 32-bit numbers
;;
;; Output:
;; : (hl) = (hl) + (de)
;;
;; Destroyed:
;; : none

	;clear the carry flag
	or a

.func adc32:
;; Add two 32-bit numbers and the carry bit
;;
;; Input:
;; : (hl), (de) - 32-bit numbers
;;
;; Output:
;; : (hl) = (hl) + (de) + cf
;;
;; Destroyed:
;; : none

	push af
	push bc
	push de
	push hl

	ld b, 4
loop:
	ld a, (de)
	adc a, (hl)
	ld (hl), a
	inc hl
	inc de
	djnz loop

	pop hl
	pop de
	pop bc
	pop af

	ret
.endf ;add32


sub32:
;; Subtract two 32-bit numbers
;;
;; Input:
;; : (hl), (de) - 32-bit numbers
;;
;; Output:
;; : (de) = (de) - (hl)
;;
;; Destroyed:
;; : none

	;clear the carry flag
	or a

.func sbc32:
;; Subtract two 32-bit numbers and the carry bit
;;
;; Input:
;; : (hl), (de) - 32-bit numbers
;;
;; Output:
;; : (de) = (de) - (hl) - cf
;;
;; Destroyed:
;; : none

	push af
	push bc
	push de
	push hl

	ld b, 4
loop:
	ld a, (de)
	sbc a, (hl)
	ld (de), a
	inc de
	inc hl
	djnz loop

	pop hl
	pop de
	pop bc
	pop af

	ret
.endf ;sub32


.func inc32:
;; Increment a 32-bit number by 1
;;
;; Input:
;; : (hl) - 32-bit number
;;
;; Output:
;; : (hl) = (hl) + 1
;;
;; Destroyed:
;; : none

	push hl

	inc (hl)
	jr nz, exit
	inc hl
	
	inc (hl)
	jr nz, exit
	inc hl

	inc (hl)
	jr nz, exit
	inc hl

	inc (hl)

exit:
	pop hl
	ret
.endf


.func dec32:
;; Decrement a 32-bit number by 1
;;
;; Input:
;; : (hl) - 32-bit number
;;
;; Output:
;; : (hl) = (hl) - 1
;;
;; Destroyed:
;; : none

	push hl

	dec (hl)
	jp p, exit
	inc hl

	dec (hl)
	jp p, exit
	inc hl

	dec (hl)
	jp p, exit
	inc hl

	dec (hl)

exit:
	pop hl
	ret

.endf


.func lshiftbyte32:
;; Shift a 32-bit number left by 1 byte
;;
;; Input:
;; : (hl) - 32-bit number
;;
;; Output:
;; : (hl) = (hl) << 8
;;
;; Destroyed:
;; : none

	push af
	push hl

	inc hl
	inc hl

	ld a, (hl)
	inc hl
	ld (hl), a
	dec hl
	dec hl

	ld a, (hl)
	inc hl
	ld (hl), a
	dec hl
	dec hl

	ld a, (hl)
	inc hl
	ld (hl), a
	dec hl
	ld (hl), 0

	pop hl
	pop af
	ret
.endf

lshift9_32:
;; Shift a 32-bit number left by 9 bits
;;
;; Input:
;; : (hl) - 32-bit number
;;
;; Output:
;; : (hl) = (hl) << 9
;;
;; Destroyed:
;; : none

	call lshiftbyte32

.func lshift32:
;; Shift a 32-bit number left by 1 bit
;;
;; Input:
;; : (hl) - 32-bit number
;;
;; Output:
;; : (hl) = (hl) << 1
;; : carry flag
;;
;; Destroyed:
;; : none

	push hl

	or a
	rl (hl)
	inc hl
	rl (hl)
	inc hl
	rl (hl)
	inc hl
	rl (hl)

	pop hl
	ret
.endf


.func rshiftbyte32:
;; Shift a 32-bit number right by 1 byte
;;
;; Input:
;; : (hl) - 32-bit number
;;
;; Output:
;; : (hl) = (hl) >> 8
;;
;; Destroyed:
;; : none

	push af
	push hl

	inc hl
	ld a, (hl)
	dec hl
	ld (hl), a
	inc hl

	inc hl
	ld a, (hl)
	dec hl
	ld (hl), a
	inc hl

	inc hl
	ld a, (hl)
	dec hl
	ld (hl), a
	inc hl

	ld (hl), 0

	pop hl
	pop af
	ret
.endf

rshift9_32:
;; Shift a 32-bit number right by 9 bits
;;
;; Input:
;; : (hl) - 32-bit number
;;
;; Output:
;; : (hl) = (hl) >> 9
;;
;; Destroyed:
;; : none

	call rshiftbyte32

.func rshift32:
;; Shift a 32-bit number right by 1 bit
;;
;; Input:
;; : (hl) - 32-bit number
;;
;; Output:
;; : (hl) = (hl) >> 1
;; : carry flag
;;
;; Destroyed:
;; : none

	or a
	inc hl
	inc hl
	inc hl

	rr (hl)
	dec hl
	rr (hl)
	dec hl
	rr (hl)
	dec hl
	rr (hl)
	ret
.endf


.func ld8:
;; Load an 8-bit number into a 32-bit pointer
;;
;; Input:
;; : a - 8-bit number
;; : hl - 32-bit pointer
;;
;; Output:
;; : (hl) = a
;;
;; Destroyed:
;; : none

	;clear (hl)
	call clear32
	ld (hl), a
	ret
.endf ;ld8


.func ld16:
;; Load a 16-bit number into a 32-bit pointer
;;
;; Input:
;; : de - 16-bit number
;; : hl - 32-bit pointer
;;
;; Output:
;; : (hl) = de
;;
;; Destroyed:
;; : none

	push hl

	ld (hl), e
	inc hl
	ld (hl), d
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), 0

	pop hl
	ret
.endf ;ld16


.func ld32:
;; Copy a 32-bit number from (hl) to (de)
;;
;; Input:
;; : (hl) - 32-bit number
;; : de - 32-bit pointer
;;
;; Destroyed:
;; : none

	push bc
	push de
	push hl

	ld bc, 4
	ldir

	pop hl
	pop de
	pop bc

	ret
.endf ;ld32


.func cp32:
;; Compares two 32-bit numbers
;;
;; Input:
;; : (hl), (de) - 32-bit numbers
;;
;; Output:
;; : c - (hl)<(de)
;; : nc - (hl)>=(de)
;; : z - (hl)=(de)
;; : nz - (hl)!=(de)
;;
;; Destroyed:
;; : a, b, de, hl

;move the pointers to the msb
	ld b, 3
startLoop:
	inc hl
	inc de
	djnz startLoop

	ld b, 4
loop:
	ld a, (de)
	cp (hl)
	ret nz
	dec hl
	dec de
	djnz loop
	ret
.endf ;cp32


.func clear32:
;; Sets a 32-bit number to 0
;;
;; Input:
;; : (hl) - 32-bit number
;;
;; Output:
;; : (hl) = 0
;;
;; Destroyed:
;; : none

	push hl
	push bc
	ld b, 4
loop:
	ld (hl), 0
	inc hl
	djnz loop

	pop bc
	pop hl
	ret
.endf ;clear32
