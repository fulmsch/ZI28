SECTION rom_code

PUBLIC u_fork

u_fork:
;; Create a child process.
;;
;; Input:
;; : None
;;
;; Output:
;; : a - errno / exit code of child
;; : e - 0: is child / -1: error / child pid
;;
;; Errors:
;; : ENOMEM - Insufficient memory available to save the current process.
;; : EPROCLIM - The limit on the number of processes has been reached.
