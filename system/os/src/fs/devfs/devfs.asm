SECTION rom_code
;; Device filesystem
PUBLIC devfs_fsDriver, devfs_fileDriver

EXTERN devfs_init, devfs_open, devfs_readdir, devfs_fstat

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
