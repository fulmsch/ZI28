SECTION rom_code
;; FAT-16 file system

INCLUDE "fatfs.h"

PUBLIC fat_fsDriver, fat_fileDriver

fat_fsDriver:
	DEFW fat_init
	DEFW fat_open
	DEFW 0x000 ;fat_close
	DEFW fat_readdir
	DEFW fat_fstat
	DEFW fat_unlink


fat_fileDriver:
	DEFW fat_read
	DEFW fat_write



SECTION ram_os

PUBLIC fat_dirEntryBuffer
fat_dirEntryBuffer:      defs 33

PUBLIC fat_clusterValue, fat_clusterValueOffset1, fat_clusterValueOffset2
fat_clusterValue:        defs 2
fat_clusterValueOffset1: defs 4
fat_clusterValueOffset2: defs 4

PUBLIC fat_rw_remCount, fat_rw_totalCount, fat_rw_dest, fat_rw_cluster, fat_rw_clusterSize
fat_rw_remCount:         defs 2
fat_rw_totalCount:       defs 2
fat_rw_dest:             defs 2
fat_rw_cluster:          defs 2
fat_rw_clusterSize:      defs 2
