;; UNIO-EEPROM Driver
;;
;; Used for identification of expansion cards

.list

unio_fileDriver:
	.dw unio_read
	.dw 0 ;write

.define UNIO_STARTHEADER 0x55
.define UNIO_READ        0x03
.define UNIO_CRRD        0x06
.define UNIO_WRITE       0x6c
.define UNIO_WREN        0x96
.define UNIO_WRDI        0x91
.define UNIO_RDSR        0x05
.define UNIO_WRSR        0x6e
.define UNIO_ERAL        0x6d
.define UNIO_SETAL       0x67

.func unio_read:
;;
;; Input:
;; : ix - file entry addr
;; : (de) - buffer
;; : bc - count
;;
;; Output:
;; : de - count
;; : a - errno

.endf ;unio_read
