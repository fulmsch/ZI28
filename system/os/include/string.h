IFNDEF STRING_H
DEFINE STRING_H

;; String manipulation routines similar to those in the C library.
;;
;; Calling convention:
;; : de - destination / str1
;; : hl - source / str2
;; : a  - char / len

EXTERN memcmp
EXTERN memset

EXTERN strcat
EXTERN strncat
EXTERN strcmp
EXTERN strncmp
EXTERN strcpy
EXTERN strncpy
EXTERN strlen
EXTERN strtup
EXTERN strbegins

EXTERN getc
EXTERN putc
EXTERN print
EXTERN printDec8, printDec16

EXTERN toupper

ENDIF
