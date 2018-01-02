SECTION rom_code
;; FAT-16 file system

PUBLIC fat_fsDriver, fat_fileDriver

EXTERN fat_init, fat_open, fat_readdir, fat_fstat, fat_unlink, fat_read, fat_write

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
