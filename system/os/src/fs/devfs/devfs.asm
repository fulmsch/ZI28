SECTION rom_code
;; Device filesystem
INCLUDE "devfs.h"

PUBLIC devfs_fsDriver, devfs_fileDriver

devfs_fsDriver:
	DEFW devfs_init
	DEFW devfs_open
	DEFW 0x0000 ;devfs_close
	DEFW devfs_readdir
	DEFW devfs_fstat
	DEFW 0x0000 ;devfs_unlink

devfs_fileDriver:
	DEFW 0x0000 ;devfs_read
	DEFW 0x0000 ;devfs_write


SECTION bram_os

PUBLIC devfsRoot, devfsRootTerminator
devfsRoot:           defs devfsEntrySize * devfsEntries
devfsRootTerminator: defs 1
