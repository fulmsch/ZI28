SECTION rom_code
; Cold start -------------------------------------------------

INCLUDE "os.h"
INCLUDE "memmap.h"
INCLUDE "vfs.h"
INCLUDE "process.h"

EXTERN dummyRoot, k_mount, k_open, k_dup, sd_init, mountRoot, k_chdir, b_cls, k_execv, k_swapon, cli, k_bsel
EXTERN swap_fd

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

	ld a, 0xff
	ld (swap_fd), a

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

	ld hl, swapFile
	call k_swapon

	ld a, 1
	ld (process_pid), a

	xor a
	call k_bsel

	ld hl, homeDir
	call k_chdir

;	call b_cls

	ld de, shellName
	ld hl, 0
	call k_execv
	jp cli

ttyName:
	DEFM "/DEV/TTY0", 0x00
osDevName:
	DEFM "/DEV/SDA1", 0x00
devfsMountPoint:
	DEFM "/DEV", 0x00
homeDir:
	DEFM "/HOME", 0x00
shellName:
	DEFM "/BIN/ZISH.EX8", 0x00
swapFile:
	DEFM "/VAR/SWAP.BIN", 0x00
