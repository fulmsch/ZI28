;; SD-Card driver
.list

sd_fileDriver:
	.dw sd_read
	.dw sd_write

;.define SD_ENABLE out (82h), a
;.define SD_DISABLE out (83h), a


.func sd_read:
;; Read a SD-Card
;;
;; Input:
;; : ix - file entry addr
;; : (de) - buffer
;; : bc - count
;;
;; Output:
;; : de = count
;; : a - errno

; Errors: 0=no error
	ld hl, sd_readblock
	jp block_read
.endf ;sd_read

.func sd_readBlock:
;; Read a block from a SD-Card
;;
;; Input:
;; : ix - file entry addr
;; : (de) - buffer
;; : (bc) - 32-bit block number
;;
;; Output:
;; : de = count
;; : a - errno

.endf


.func sd_write:
;; Input:
;; : ix - file entry addr
;; : (de) - buffer
;; : bc - count
;;
;; Output:
;; : de - count
;; : a - errno

; Errors: 0=no error

	ret

.endf ;sd_write


;.func delay100:
;	;Wait for approx. 100ms
;	ld b, 0
;	ld c, 41
;loop:
;	ex (sp), hl
;	ex (sp), hl
;	ex (sp), hl
;	ex (sp), hl
;	djnz delay100Loop
;	dec c
;	jr nz, delay100Loop
;	ret
;.endf ;delay100
