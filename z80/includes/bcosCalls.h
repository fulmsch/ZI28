#define bcosVect     5003h

#define bcosStart    0
#define openFile     1
#define closeFile    2
#define readFile     3
#define setProcTable 4


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
