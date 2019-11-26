;; OS entry and call table
;ZI-28 OS
;Florian Ulmschneider 2016-2017

;TODO:

#target rom

#data RAM,0x4000,0x4000

#code ROM,0,0x4000

#include "../../../include/asm/os.h"
#include "../../../include/asm/iomap.h"
#include "../../../include/asm/errno.h"

#define sysStack 0x8000

; Jump Table -------------------------------------------------

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


	org 0x66
	DEFW ISR_keyboard

	org 0x100
#include "syscall.asm"

#include "math.asm"
#include "string.asm"

#include "coldstart.asm"
#include "chdir.asm"
#include "error.asm"
#include "font.asm"
#include "get_drive_and_path.asm"
#include "getcwd.asm"
#include "interrupt.asm"
#include "kalloc.asm"
#include "monitor.asm"
#include "realpath.asm"

#include "process/process.asm"
#include "fs/vfs/vfs.asm"
#include "fs/fatfs/fatfs.asm"
#include "fs/devfs/devfs.asm"

#include "shell/cli.asm"
#include "version.asm"

#include "bank/bsel.asm"
#include "block/block.asm"

#include "drivers/ft240/ft240.asm"
#include "drivers/sd/sd.asm"
#include "drive/drive.asm"



#data RAM
;; SECTION RAM ;0x4000 - 0x7fff, 16kB
	;; org 0x4000

;; SECTION ram_driveTable
;; SECTION ram_fileTable
;; SECTION ram_fdTable

;; SECTION ram_os

;; PUBLIC kheap
;; SECTION ram_kheap
kheap:

#end
