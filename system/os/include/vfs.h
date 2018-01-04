IFNDEF VFS_H
DEFINE VFS_H

DEFC fileTableMode        = 0                        ;1 byte
DEFC fileTableRefCount    = fileTableMode + 1        ;1 byte
DEFC fileTableDriveNumber = fileTableRefCount + 1    ;1 byte
DEFC fileTableDriver      = fileTableDriveNumber + 1 ;2 bytes
DEFC fileTableOffset      = fileTableDriver + 2      ;4 bytes
DEFC fileTableSize        = fileTableOffset + 4      ;4 bytes
                                                     ;-------
                                               ;Total 13 bytes
DEFC fileTableData        = fileTableSize + 4  ;Max   19 bytes


DEFC file_read  = 0
DEFC file_write = 2

DEFC fileTableEntrySize = 32
DEFC fileTableEntries   = 32
EXTERN fileTable

DEFC fdTableEntries = 32
EXTERN u_fdTable, k_fdTable

ENDIF
