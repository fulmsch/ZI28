;; Contains the memory map of used by the OS
#define sysStack   8000h
#define monStack   4200h

;#define sdBuffer   4200h

;BIOS memory map
#define memBase    0000h

#define nmiEntry   memBase + 66h


;Monitor workspace
#define monWorkspace            4200h
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

#define reg32                   terminalFd + 1
#define osWorkspaceEnd          reg32 + 4

;Device Fs
#define devfsEntrySize          16
#define devfsEntries            32

#define devfsRoot               osWorkspaceEnd
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

;Block driver
#define block_buffer            fileTableEnd
#define sdBuffer block_buffer ;legacy
#define block_curBlock          block_buffer + 512
#define block_endBlock          block_curBlock + 4
#define block_remCount          block_endBlock + 4
#define block_relOffs           block_remCount + 2
#define block_callback          block_relOffs + 2
#define block_dest              block_callback + 2
#define block_end               block_dest + 2

;k_open
#define k_open_mode             block_end
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

