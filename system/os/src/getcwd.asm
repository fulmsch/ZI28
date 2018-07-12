SECTION rom_code
INCLUDE "string.h"
INCLUDE "process.h"

PUBLIC u_getcwd, k_getcwd

u_getcwd:
k_getcwd:
;; Return the current working directory
;;
;; Input:
;; : (hl) - buffer
;;
;; Output:
;; : a - errno

	ex de, hl
	ld hl, process_workingDir
	call strcpy
	xor a
	ret
