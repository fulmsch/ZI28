SECTION rom_code

PUBLIC u_exit

EXTERN kernel_stackSave

u_exit:
;; Terminate the current process and return control to the parent.
;;
;; Input:
;; : a - exit status

;TODO what to do if trying to exit pid 1?
; - reboot the system
; - display reboot prompt
; - drop to kernel shell
; - halt the system / panic

;TODO close all fds

	ld sp, (kernel_stackSave)

EXTERN cli
	jp cli
