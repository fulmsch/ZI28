#define bcosVect     5003h

#define bcosStart    0
#define openFile     1
#define closeFile    2
#define readFile     3
#define writeFile    4
#define chdir        5
#define setDrive     6
#define setProcTable 7


;*****************
;openFile
;Description: creates a new file table entry
;Inputs: (de) = pathname, a = mode
;Outputs: e = file descriptor, a = errno
;Errors: 0=no error
;        1=maximum allowed files already open
;        2=no matching file found
;        3=file too large
;Destroyed: all


;*****************
;closeFile
;Description: close a file table entry
;Inputs: a = file descriptor
;Outputs: a = errno
;Errors: 0=no error
;        1=invalid file descriptor
;Destroyed: none


;*****************
;readFile
;Description: copy data from a file to memory
;Inputs: a = file descriptor, (de) = buffer, hl = count
;Outputs: a = errno, de = count
;Errors: 0=no error
;        1=invalid file descriptor
;Destroyed: none


;*****************
;chdir
;Description: change the working directory of the active process
;Inputs: 
;Outputs: a = errno
;Errors: 0=no error
;Destroyed: 


;*****************
;readFile
;Description: copy data from a file to memory
;Inputs: a = file descriptor, (de) = buffer, hl = count
;Outputs: a = errno, de = count
;Errors: 0=no error
;        1=invalid file descriptor
;Destroyed: none


;*****************
;readFile
;Description: copy data from a file to memory
;Inputs: a = file descriptor, (de) = buffer, hl = count
;Outputs: a = errno, de = count
;Errors: 0=no error
;        1=invalid file descriptor
;Destroyed: none

;*****************
;setDrive
;Description: set default drive number
;Inputs: a = drive number
;Outputs: a = errno
;Errors: 0=no error
;        1=drive doesn't exist
;        2=drive access error
;Destroyed: 
