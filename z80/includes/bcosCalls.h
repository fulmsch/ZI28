bcosVect  equ 5003h

bcosStart equ 0
openFile  equ 1
closeFile equ 2
readFile  equ 3


;******************************************************************************
;openFile
;Call:
; (de)      a
; pathname  mode
;
;Return:
; e                a
; file descriptor  error
;
;Modes:
;
;
;Errors: 0=no error
;        1=maximum allowed files already open
;        2=no matching file found
;        3=file too large
;******************************************************************************


;******************************************************************************
;readFile
;Call:
; a                (de)    hl
; file descriptor  buffer  count
;
;Return:
; de     a
; count  error
;
;Errors: 0=no error
;        1=invalid file descriptor
;******************************************************************************
