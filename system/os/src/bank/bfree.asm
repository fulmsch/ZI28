SECTION rom_code

PUBLIC u_bfree

u_bfree:
;; Release a bank back to the system.
;;
;; The specified bank must be allocated to the calling process and not
;; currently selected.
;;
;; Input:
;; : a - bank index
;;
;; Output:
;; : a - errno
;;
;; Errors:
;; : EINVAL - Invalid bank index
