SECTION rom_code
PUBLIC sd_getResponse

EXTERN sd_transferByte, sd_getResponse

sd_getResponse:
;; Look for a specific response from the SD-card
;;
;; Input:
;; : e - expected response
;; : b - number of retries
;; : c - base port address
;;
;; Output:
;; : carry - timeout
;; : nc - got correct response
;;
;; Destroyed:
;; : a, b

	call sd_transferByte
	in a, (c)
	cp e
	ret z
	djnz sd_getResponse

timeout:
	scf
