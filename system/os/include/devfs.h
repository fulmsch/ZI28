IFNDEF DEVFS_H
DEFINE DEVFS_H

INCLUDE "vfs.h"

EXTERN devfs_init, devfs_open, devfs_readdir, devfs_fstat
EXTERN devfsRoot, devfsRootTerminator

DEFC devfs_name        =  0
DEFC devfs_entryDriver =  8
DEFC devfs_number      = 10
DEFC devfs_data        = 11

DEFC dev_fileTableDirEntry = fileTableData ;Pointer to entry in devfs
DEFC dev_fileTableNumber   = dev_fileTableDirEntry + 2
DEFC dev_fileTableData     = dev_fileTableNumber + 1

DEFC devfsEntrySize = 16
DEFC devfsEntries   = 32

ENDIF
