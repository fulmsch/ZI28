IFNDEF SD_H
DEFINE SD_H

INCLUDE "devfs.h"

DEFC sd_fileTableStartSector = dev_fileTableData

;SD command set
DEFC SD_GO_IDLE_STATE     =  0 + 0x40 ;Software reset
DEFC SD_SEND_OP_COND      =  1 + 0x40 ;Initiate initialization process
DEFC SD_SET_BLOCKLEN      = 16 + 0x40 ;Change R/W block size
DEFC SD_READ_SINGLE_BLOCK = 17 + 0x40 ;Read a block
DEFC SD_WRITE_BLOCK       = 24 + 0x40 ;Write a block
DEFC SD_READ_OCR          = 58 + 0x40 ;Read OCR

EXTERN sd_read, sd_write, sd_readBlock, sd_writeBlock
EXTERN sd_enable, sd_disable, sd_transferByte, delay100
EXTERN sd_sendCmd, sd_getResponse
EXTERN sd_blockCallback

ENDIF
