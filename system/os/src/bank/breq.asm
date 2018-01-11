SECTION rom_code

PUBLIC u_breq

u_breq:
;; Request a new bank to the current process.
;;
;; If the call was successful, the new bank is selected.
;;
;; Input:
;; : None
;;
;; Output:
;; : a - errno
;; : e - bank index
;;
;; Errors:
;; : ENOMEM - No new bank available.
