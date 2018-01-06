SECTION rom_code
; Cold start -------------------------------------------------

INCLUDE "os.h"
INCLUDE "memmap.h"
INCLUDE "vfs.h"

EXTERN dummyRoot, k_mount, k_open, k_dup, sd_init, mountRoot, k_chdir, b_cls, cli

PUBLIC _coldStart
_coldStart:
	ld sp, sysStack

	;clear ram TODO other banks
	ld hl, 0x4000
	ld de, 0x4001
	ld bc, 0xbfff
	ld (hl), 0x00
	ldir

	;clear the fd tables (set everything to 0xff)
	ld hl, k_fdTable
	ld de, k_fdTable + 1
	ld bc, fdTableEntries * 2 - 1
	ld (hl), 0xff
	ldir

	call dummyRoot
	ld hl, devfsMountPoint
	ld d, FS_DEV
	ld e, 0xff
	call k_mount

	;stdin
	ld de, ttyName
	ld a, O_RDONLY
	call k_open

	;stdout
	ld de, ttyName
	ld a, O_WRONLY
	call k_open

	;stderr
	ld a, STDERR_FILENO
	ld b, STDOUT_FILENO
	call k_dup


	call sd_init ;TODO automatic init

	;initialise main drive
	ld de, osDevName ;TODO configurable name in eeprom
	ld a, FS_FAT
	call mountRoot


	ld hl, homeDir
	call k_chdir

	call b_cls
	jp cli

ttyName:
	DEFM "/DEV/TTY0", 0x00
osDevName:
	DEFM "/DEV/SDA1", 0x00
devfsMountPoint:
	DEFM "/DEV", 0x00
homeDir:
	DEFM "/HOME", 0x00
