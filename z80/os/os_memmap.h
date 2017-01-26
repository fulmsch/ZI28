#define sysStack   8000h
#define monStack   4200h

#define sdBuffer   4200h

;BIOS memory map
#define memBase    0000h

#define nmiEntry   memBase + 66h


;Monitor workspace
#define monWorkspace               4000h
#define monInputBuffer             monWorkspace + 0
#define monInputBufferSize         40h
#define lineCounter             monInputBuffer + monInputBufferSize

#define xmodemRecvPacketNumber  lineCounter + 1
#define xmodemRecvPacketAddress xmodemRecvPacketNumber + 1

#define header                  xmodemRecvPacketAddress + 1
#define byteCountField          header + 0
#define addressField            byteCountField + 2
#define recordTypeField         addressField + 4

#define outputDev               recordTypeField + 2
#define inputDev                outputDev + 1

#define stackSave               inputDev + 1
#define registerStackBot        stackSave + 2
#define registerStack           stackSave +14

