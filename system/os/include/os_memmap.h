IFNDEF OS_MEMMAP_H
DEFINE OS_MEMMAP_H

INCLUDE "os.h"


;Monitor workspace
DEFC monWorkspace            = 0xb200
DEFC monInputBuffer          = monWorkspace + 0
DEFC monInputBufferSize      = 40h
DEFC lineCounter             = monInputBuffer + monInputBufferSize

DEFC xmodemRecvPacketNumber  = lineCounter + 1
DEFC xmodemRecvPacketAddress = xmodemRecvPacketNumber + 1

DEFC header                  = xmodemRecvPacketAddress + 1
DEFC byteCountField          = header + 0
DEFC addressField            = byteCountField + 2
DEFC recordTypeField         = addressField + 4

DEFC outputDev               = recordTypeField + 2
DEFC inputDev                = outputDev + 1

DEFC stackSave               = inputDev + 1
DEFC registerStackBot        = stackSave + 2
DEFC registerStack           = stackSave +14

ENDIF
