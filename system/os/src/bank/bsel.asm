SECTION rom_code

PUBLIC u_bsel

u_bsel:
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
