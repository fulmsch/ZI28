;drive table
.define fat_fat1StartAddr     driveTableFsdata          ;4 bytes
.define fat_fat2StartAddr     fat_fat1StartAddr + 4     ;4 bytes
.define fat_rootDirStartAddr  fat_fat2StartAddr + 4     ;4 bytes
.define fat_dataStartAddr     fat_rootDirStartAddr + 4  ;4 bytes
.define fat_sectorsPerCluster fat_dataStartAddr + 4     ;1 byte
.define fat_firstFreeCluster  fat_sectorsPerCluster + 2 ;2 bytes
                                                 ;Total 19 bytes


.define fat_fileTableStartCluster fileTableData                 ;2 bytes
.define fat_fileTableDirEntryAddr fat_fileTableStartCluster + 2 ;4 bytes

;file attributes
.define FAT_ATTRIB_RDONLY  0
.define FAT_ATTRIB_HIDDEN  1
.define FAT_ATTRIB_SYSTEM  2
.define FAT_ATTRIB_VOLLBL  3
.define FAT_ATTRIB_DIR     4
.define FAT_ATTRIB_ARCHIVE 5
.define FAT_ATTRIB_DEVICE  6


;Boot sector contents             Offset|Length (in bytes)
.define FAT_VBR_OEM_NAME             03h ;8
.define FAT_VBR_BYTES_PER_SECTOR     0bh ;2
.define FAT_VBR_SECTORS_PER_CLUSTER  0dh ;1
.define FAT_VBR_RESERVED_SECTORS     0eh ;2
.define FAT_VBR_FAT_COPIES           10h ;1
.define FAT_VBR_MAX_ROOT_DIR_ENTRIES 11h ;2
.define FAT_VBR_SECTORS_SHORT        13h ;2
.define FAT_VBR_MEDIA_DESCRIPTOR     15h ;1
.define FAT_VBR_SECTORS_PER_FAT      16h ;2
.define FAT_VBR_SECTORS_PER_TRACK    18h ;2
.define FAT_VBR_HEADS                1ah ;4
.define FAT_VBR_SECTORS_BEFORE_VBR   1ch ;4
.define FAT_VBR_SECTORS_LONG         20h ;1
.define FAT_VBR_DRIVE_NUMBER         24h ;1
.define FAT_VBR_BOOT_RECORD_SIG      26h ;1
.define FAT_VBR_SERIAL_NUMBER        27h ;4
