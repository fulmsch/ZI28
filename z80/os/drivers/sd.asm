.list

; SD-Card driver

sd_fileDriver:
	.dw sd_read
	.dw sd_write
;	.dw sd_seek


.func sd_read:
;; Inputs: ix = file entry addr, (de) = buffer, bc = count
;; a = errno, de = count
;; Errors: 0=no error

.endf ;sd_read


.func sd_write:
;; Inputs: ix = file entry addr, (de) = buffer, bc = count
;; a = errno, de = count
;; Errors: 0=no error

.endf ;sd_write
