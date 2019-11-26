#code ROM

u_bsel:
k_bsel:
;; Switch to a different bank.
;;
;; On failure, the current bank stays selected.
;; This system call can also be used to determine the currently selected bank
;; by calling it with an invalid bank index.
;;
;; Input:
;; : a - bank index
;;
;; Output:
;; : a - errno
;; : e - selected bank
;;
;; Errors:
;; : EINVAL - invalid bank index

#local
	cp 6
	jr c, error

	or a, 0x08 ;make sure OS rom bank stays selected
	out (BANKSEL_PORT), a
	ld (process_bank), a
	ld e, a
	xor a
	ret

error:
	ld a, (process_bank)
	ld e, a
	ld a, EINVAL
	ret
#endlocal
