IFNDEF FATFS_H
DEFINE FATFS_H

INCLUDE "drive.h"
INCLUDE "vfs.h"

;drive table
DEFC fat_fat1StartAddr     = driveTableFsData          ;4 bytes
DEFC fat_fat2StartAddr     = fat_fat1StartAddr + 4     ;4 bytes
DEFC fat_rootDirStartAddr  = fat_fat2StartAddr + 4     ;4 bytes
DEFC fat_dataStartAddr     = fat_rootDirStartAddr + 4  ;4 bytes
DEFC fat_sectorsPerCluster = fat_dataStartAddr + 4     ;1 byte
DEFC fat_firstFreeCluster  = fat_sectorsPerCluster + 2 ;2 bytes
                                                 ;Total 19 bytes


DEFC fat_fileTableStartCluster = fileTableData                 ;2 bytes
DEFC fat_fileTableDirEntryAddr = fat_fileTableStartCluster + 2 ;4 bytes


EXTERN fat_init, fat_open, fat_readdir, fat_fstat, fat_unlink, fat_read, fat_write
EXTERN fat_build83Filename
EXTERN fat_fileDriver, fat_dirEntryBuffer
EXTERN fat_clusterValue, fat_clusterValueOffset1, fat_clusterValueOffset2
EXTERN fat_rw_remCount, fat_rw_totalCount, fat_rw_dest, fat_rw_cluster, fat_rw_clusterSize

;file attributes
DEFC FAT_ATTRIB_RDONLY  = 0
DEFC FAT_ATTRIB_HIDDEN  = 1
DEFC FAT_ATTRIB_SYSTEM  = 2
DEFC FAT_ATTRIB_VOLLBL  = 3
DEFC FAT_ATTRIB_DIR     = 4
DEFC FAT_ATTRIB_ARCHIVE = 5
DEFC FAT_ATTRIB_DEVICE  = 6


;Boot sector contents              Offset|Length (in bytes)
DEFC FAT_VBR_OEM_NAME             = 0x03 ;8
DEFC FAT_VBR_BYTES_PER_SECTOR     = 0x0b ;2
DEFC FAT_VBR_SECTORS_PER_CLUSTER  = 0x0d ;1
DEFC FAT_VBR_RESERVED_SECTORS     = 0x0e ;2
DEFC FAT_VBR_FAT_COPIES           = 0x10 ;1
DEFC FAT_VBR_MAX_ROOT_DIR_ENTRIES = 0x11 ;2
DEFC FAT_VBR_SECTORS_SHORT        = 0x13 ;2
DEFC FAT_VBR_MEDIA_DESCRIPTOR     = 0x15 ;1
DEFC FAT_VBR_SECTORS_PER_FAT      = 0x16 ;2
DEFC FAT_VBR_SECTORS_PER_TRACK    = 0x18 ;2
DEFC FAT_VBR_HEADS                = 0x1a ;4
DEFC FAT_VBR_SECTORS_BEFORE_VBR   = 0x1c ;4
DEFC FAT_VBR_SECTORS_LONG         = 0x20 ;1
DEFC FAT_VBR_DRIVE_NUMBER         = 0x24 ;1
DEFC FAT_VBR_BOOT_RECORD_SIG      = 0x26 ;1
DEFC FAT_VBR_SERIAL_NUMBER        = 0x27 ;4

ENDIF
