.list
;; Contains the memory map of used by the OS
#define sysStack   0xc000
#define monStack   0xa200

;BIOS memory map
#define memBase    0000h

#define nmiEntry   memBase + 66h


;Monitor workspace
#define monWorkspace            0xa200
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

;32-bit registers
#define regA                    osWorkspace + 1
#define reg32                   regA
#define regB                    regA + 4
#define regC                    regB + 4

#define getc_buffer             regC + 4
#define putc_buffer             getc_buffer + 1

#define pathBuffer              putc_buffer + 1

#define osWorkspaceEnd          pathBuffer + PATH_MAX

;Environment
#define env_workingPath         osWorkspaceEnd             ;PATH_MAX bytes
#define env_end                 env_workingPath + PATH_MAX

;Device Fs
#define devfsEntrySize          16
#define devfsEntries            32

#define devfsRoot               env_end
#define devfsRootTerminator     devfsRoot + devfsEntrySize * devfsEntries
#define devfsRootEnd            devfsRootTerminator + 1

;Drive Table
#define driveTableEntrySize     32
#define driveTableEntries       8

#define driveTable              0x0100 + ((devfsRootEnd) & 0xff00)
#define driveTablePaths         driveTable + (driveTableEntrySize * driveTableEntries)
#define driveTableEnd           driveTablePaths + (driveTableEntrySize * driveTableEntries)

;File Table
#define fileTableEntrySize      32
#define fileTableEntries        32

;TODO align to 256 byte boundary, add second table just for names
#define fileTable               driveTableEnd
#define fileTableEnd            fileTable + fileTableEntrySize * fileTableEntries

;File descriptors
#define fdTableEntries          32

#define k_fdTable               fileTableEnd
#define u_fdTable               k_fdTable + fdTableEntries
#define fdTableEnd              u_fdTable + fdTableEntries

;Block driver
#define block_buffer            fdTableEnd
#define block_curBlock          block_buffer + 512
#define block_endBlock          block_curBlock + 4
#define block_remCount          block_endBlock + 4
#define block_totalCount        block_remCount + 2
#define block_relOffs           block_totalCount + 2
#define block_readCallback      block_relOffs + 2
#define block_writeCallback     block_readCallback + 2
#define block_memPtr            block_writeCallback + 2
#define block_end               block_memPtr + 2

;k_open
#define k_open_mode             block_end
#define k_open_fd               k_open_mode + 1
#define k_open_fileIndex        k_open_fd + 1
#define k_open_path             k_open_fileIndex + 1
#define k_open_drive            k_open_path + 2
#define k_open_end              k_open_drive + 1

;k_dup
#define k_dup_oldFd             k_open_end
#define k_dup_newFd             k_dup_oldFd + 1
#define k_dup_end               k_dup_newFd + 1

;k_seek
#define k_seek_new              k_open_end
#define k_seek_end              k_seek_new + 4

;fat
#define fat_clusterValue        k_seek_end                 ;2 bytes
#define fat_clusterValueOffset1 fat_clusterValue + 2         ;4 bytes
#define fat_clusterValueOffset2 fat_clusterValueOffset1 + 4  ;4 bytes

;fat_open
#define fat_open_path           fat_clusterValueOffset2 + 4  ;2 bytes
#define fat_open_originalPath   fat_open_path + 2            ;2 bytes
#define fat_open_flags          fat_open_originalPath + 2    ;1 bytes
#define fat_open_freeEntry      fat_open_flags + 1           ;4 bytes
#define fat_open_filenameBuffer fat_open_freeEntry + 4       ;11 bytes
#define fat_dirEntryBuffer      fat_open_filenameBuffer + 11 ;33 bytes
#define fat_open_end            fat_dirEntryBuffer + 33

;fat_read/write
#define fat_rw_remCount         fat_open_end
#define fat_rw_totalCount       fat_rw_remCount + 2
#define fat_rw_dest             fat_rw_totalCount + 2
#define fat_rw_cluster          fat_rw_dest + 2
#define fat_rw_clusterSize      fat_rw_cluster + 2
#define fat_rw_end              fat_rw_clusterSize + 2

;exec
#define exec_addr               0x4000
#define exec_stack              fat_rw_end       ;2 bytes
#define exec_fd                 exec_stack + 2   ;1 byte
#define exec_end                exec_fd + 1

;realpath
#define realpath_outputProt     exec_end
#define realpath_output         realpath_outputProt + 1
#define realpath_end            realpath_output + PATH_MAX

;cli
#define cliWorkspace            realpath_end

#define inputBufferSize         128
#define maxArgc                 32

#define inputBuffer             cliWorkspace
#define inputBufferEnd          inputBuffer + inputBufferSize

#define argc                    inputBufferEnd
#define argv                    argc + 1
#define argvEnd                 argv + maxArgc * 2

#define cli_programName          argvEnd
#define cli_programNameEnd       cli_programName + 13
