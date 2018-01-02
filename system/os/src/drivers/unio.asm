SECTION rom_code
;; UNIO-EEPROM Driver
;;
;; Used for identification of expansion cards

unio_fileDriver:
	DEFW unio_read
	DEFW 0 ;write

DEFC UNIO_STARTHEADER = 0x55
DEFC UNIO_READ        = 0x03
DEFC UNIO_CRRD        = 0x06
DEFC UNIO_WRITE       = 0x6c
DEFC UNIO_WREN        = 0x96
DEFC UNIO_WRDI        = 0x91
DEFC UNIO_RDSR        = 0x05
DEFC UNIO_WRSR        = 0x6e
DEFC UNIO_ERAL        = 0x6d
DEFC UNIO_SETAL       = 0x67

unio_read:
;;
;; Input:
;; : ix - file entry addr
;; : (de) - buffer
;; : bc - count
;;
;; Output:
;; : de - count
;; : a - errno

