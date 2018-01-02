;; OS entry and call table
;ZI-28 OS
;Florian Ulmschneider 2016-2017

;TODO:

INCLUDE "os_memmap.h"

; Jump Table -------------------------------------------------

org 0x0000

EXTERN _coldStart, _putc, _getc, _strerror, _syscall, _monitor

	jp      _coldStart   ;RST 0x00
	DEFB    0x00
	jp      0x00         ;CALL 0x04
	DEFB    0x00
	jp      _putc        ;RST 0x08
	DEFB    0x00
	jp      0x00         ;CALL 0x0C
	DEFB    0x00
	jp      _getc        ;RST 0x10
	DEFB    0x00
	jp      0x00         ;CALL 0x14
	DEFB    0x00
	jp      0x00         ;RST 0x18
	DEFB    0x00
	jp      0x00         ;CALL 0x1C
	DEFB    0x00
	jp      0x00         ;RST 0x20
	DEFB    0x00
	jp      0x00         ;CALL 0x24
	DEFB    0x00
	jp      _strerror    ;RST 0x28
	DEFB    0x00
	jp      0x00         ;CALL 0x2C
	DEFB    0x00
	jp      _syscall     ;RST 0x30
	DEFB    0x00
	jp      0x00         ;CALL 0x34
	DEFB    0x00
	jp      _monitor     ;RST 0x38


;SECTION rom_nmi
DEFS nmiEntry - ASMPC
EXTERN ISR_keyboard
	DEFW ISR_keyboard

;SECTION rom_syscallTable
DEFS 0x0100 - ASMPC
PUBLIC syscallTable, syscallTableEnd
EXTERN u_open, u_close, u_read, u_write, u_seek, u_lseek, u_stat, u_fstat
EXTERN u_readdir, u_dup, u_mount, u_unmount, u_unlink
syscallTable:
	DEFW u_open
	DEFW u_close
	DEFW u_read
	DEFW u_write
	DEFW u_seek
	DEFW u_lseek
	DEFW u_stat
	DEFW u_fstat
	DEFW u_readdir
	DEFW u_dup
	DEFW u_mount
	DEFW u_unmount
	DEFW u_unlink
syscallTableEnd:
DEFB 0

SECTION rom_code
SECTION rom_data


SECTION BSS
org 0xc000

SECTION bss_fileTable
SECTION bss_driveTable
org 0xc200

SECTION bss_os
