SECTION rom_code

PUBLIC u_execv

u_execv:
;; Execute a program.
;;
;; Input:
;; : (de) - path
;; : (hl) - argv
;;
;; Output:
;; : a - errno
;;
;; Errors:
;; : E2BIG - The argument list (argv) is too big.
;; : EACCES, EIO, ENFILE, ENAMETOOLONG, ENOENT, ENOTDIR
