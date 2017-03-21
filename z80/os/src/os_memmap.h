;; Contains the memory map of used by the OS
#define sysStack   8000h
#define monStack   4200h

#define sdBuffer   4200h

;BIOS memory map
#define memBase    0000h

#define nmiEntry   memBase + 66h


;Monitor workspace
#define monWorkspace            5000h
#define monInputBuffer          monWorkspace + 0
#define monInputBufferSize      40h
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

;OS workspace
#define osWorkspace             registerStack
#define terminalFd              osWorkspace

;Device Fs
#define devfsEntrySize          16
#define devfsEntries            32

#define devfsRoot               terminalFd + 1
#define devfsRootTerminator     devfsRoot + devfsEntrySize * devfsEntries
#define devfsRootEnd            devfsRootTerminator + 1

;Drive Table
#define driveTableEntrySize     32
#define driveTableEntries       9

#define driveTable              devfsRootEnd
#define driveTableEnd           driveTable + driveTableEntrySize * driveTableEntries

;File Table
#define fileTableEntrySize      32
#define fileTableEntries        32

#define fileTable               driveTableEnd
#define fileTableEnd            fileTable + fileTableEntrySize * fileTableEntries

;k_open
#define k_open_mode             fileTableEnd
#define k_open_fd               k_open_mode + 1
#define k_open_path             k_open_fd + 1
#define k_open_drive            k_open_path + 2
#define k_open_end              k_open_drive + 1

;k_seek
#define k_seek_new              k_open_end
#define k_seek_end              k_seek_new + 4

;cli
#define cliWorkspace            k_seek_end

#define inputBufferSize         128
#define maxArgc                 32

#define inputBuffer             cliWorkspace
#define inputBufferEnd          inputBuffer + inputBufferSize

#define argc                    inputBufferEnd
#define argv                    argc + 1
#define argvEnd                 argv + maxArgc * 2

#define cliProgramName          argvEnd
#define cliProgramNameEnd       cliProgramName + 13

