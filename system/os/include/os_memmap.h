IFNDEF OS_MEMMAP_H
DEFINE OS_MEMMAP_H

INCLUDE "os.h"

DEFC nmiEntry = 0x66

DEFC monStack   = 0xa200
DEFC sysStack = 0xc000


;Monitor workspace
DEFC monWorkspace            = 0xa200
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

;OS workspace
DEFC osWorkspace             = registerStack

;32-bit registers
DEFC regA                    = osWorkspace + 1
DEFC reg32                   = regA
DEFC regB                    = regA + 4
DEFC regC                    = regB + 4

DEFC getc_buffer             = regC + 4
DEFC putc_buffer             = getc_buffer + 1

DEFC pathBuffer              = putc_buffer + 1

DEFC osWorkspaceEnd          = pathBuffer + PATH_MAX

;Environment
DEFC env_workingPath         = osWorkspaceEnd             ;PATH_MAX bytes
DEFC env_end                 = env_workingPath + PATH_MAX

;Device Fs
DEFC devfsEntrySize          = 16
DEFC devfsEntries            = 32

DEFC devfsRoot               = env_end
DEFC devfsRootTerminator     = devfsRoot + devfsEntrySize * devfsEntries
DEFC devfsRootEnd            = devfsRootTerminator + 1

;Drive Table
DEFC driveTableEntrySize     = 32
DEFC driveTableEntries       = 8

DEFC driveTable              = 0x0100 + ((devfsRootEnd) & 0xff00)
DEFC driveTablePaths         = driveTable + (driveTableEntrySize * driveTableEntries)
DEFC driveTableEnd           = driveTablePaths + (driveTableEntrySize * driveTableEntries)

;File Table
DEFC fileTableEntrySize      = 32
DEFC fileTableEntries        = 32

;TODO align to 256 byte boundary, add second table just for names
DEFC fileTable               = driveTableEnd
DEFC fileTableEnd            = fileTable + fileTableEntrySize * fileTableEntries

;File descriptors
DEFC fdTableEntries          = 32

DEFC k_fdTable               = fileTableEnd
DEFC u_fdTable               = k_fdTable + fdTableEntries
DEFC fdTableEnd              = u_fdTable + fdTableEntries

;Block driver
DEFC block_buffer            = fdTableEnd
DEFC block_curBlock          = block_buffer + 512
DEFC block_endBlock          = block_curBlock + 4
DEFC block_remCount          = block_endBlock + 4
DEFC block_totalCount        = block_remCount + 2
DEFC block_relOffs           = block_totalCount + 2
DEFC block_readCallback      = block_relOffs + 2
DEFC block_writeCallback     = block_readCallback + 2
DEFC block_memPtr            = block_writeCallback + 2
DEFC block_end               = block_memPtr + 2

;k_open
DEFC k_open_mode             = block_end
DEFC k_open_fd               = k_open_mode + 1
DEFC k_open_fileIndex        = k_open_fd + 1
DEFC k_open_path             = k_open_fileIndex + 1
DEFC k_open_drive            = k_open_path + 2
DEFC k_open_end              = k_open_drive + 1

;k_dup
DEFC k_dup_oldFd             = k_open_end
DEFC k_dup_newFd             = k_dup_oldFd + 1
DEFC k_dup_end               = k_dup_newFd + 1

;k_seek
DEFC k_seek_new              = k_open_end
DEFC k_seek_end              = k_seek_new + 4

;fat
DEFC fat_clusterValue        = k_seek_end                 ;2 bytes
DEFC fat_clusterValueOffset1 = fat_clusterValue + 2         ;4 bytes
DEFC fat_clusterValueOffset2 = fat_clusterValueOffset1 + 4  ;4 bytes

;fat_open
DEFC fat_open_path           = fat_clusterValueOffset2 + 4  ;2 bytes
DEFC fat_open_originalPath   = fat_open_path + 2            ;2 bytes
DEFC fat_open_flags          = fat_open_originalPath + 2    ;1 bytes
DEFC fat_open_freeEntry      = fat_open_flags + 1           ;4 bytes
DEFC fat_open_filenameBuffer = fat_open_freeEntry + 4       ;11 bytes
DEFC fat_dirEntryBuffer      = fat_open_filenameBuffer + 11 ;33 bytes
DEFC fat_open_end            = fat_dirEntryBuffer + 33

;fat_read/write
DEFC fat_rw_remCount         = fat_open_end
DEFC fat_rw_totalCount       = fat_rw_remCount + 2
DEFC fat_rw_dest             = fat_rw_totalCount + 2
DEFC fat_rw_cluster          = fat_rw_dest + 2
DEFC fat_rw_clusterSize      = fat_rw_cluster + 2
DEFC fat_rw_end              = fat_rw_clusterSize + 2

;exec
DEFC exec_addr               = 0x4000
DEFC exec_stack              = fat_rw_end       ;2 bytes
DEFC exec_fd                 = exec_stack + 2   ;1 byte
DEFC exec_end                = exec_fd + 1

;realpath
DEFC realpath_outputProt     = exec_end
DEFC realpath_output         = realpath_outputProt + 1
DEFC realpath_end            = realpath_output + PATH_MAX

;cli
DEFC cliWorkspace            = realpath_end

DEFC inputBufferSize         = 128
DEFC maxArgc                 = 32

DEFC inputBuffer             = cliWorkspace
DEFC inputBufferEnd          = inputBuffer + inputBufferSize

DEFC argc                    = inputBufferEnd
DEFC argv                    = argc + 1
DEFC argvEnd                 = argv + maxArgc * 2

DEFC cli_programName         = argvEnd
DEFC cli_programNameEnd      = cli_programName + 13

ENDIF
