;ZI-28 OS
;Florian Ulmschneider 2016-2017

;TODO:


.z80


.include "iomap.h"
.include "os_memmap.h"
.include "osCalls.h"


; Jump Table -------------------------------------------------

.org memBase

	jp      _coldStart   ;RST 00h
	.db     00h
	jp      00h          ;CALL 04h
	.db     00h
	jp      _putc        ;RST 08h
	.db     00h
	jp      _setOutput   ;CALL 0Ch
	.db     00h
	jp      _getc        ;RST 10h
	.db     00h
	jp      _setInput    ;CALL 14h
	.db     00h
	jp      00h          ;RST 18h
	.db     00h
	jp      00h          ;CALL 1Ch
	.db     00h
	jp      _sdRead      ;RST 20h
	.db     00h
	jp      00h          ;CALL 24h
	.db     00h
	jp      00h          ;RST 28h
	.db     00h
	jp      00h          ;CALL 2Ch
	.db     00h
	jp      00h          ;RST 30h set bank
	.db     00h
	jp      00h          ;CALL 34h
	.db     00h
	jp      _monitor     ;RST 38h

	jp      k_open
	jp      k_close
	jp      k_read
	jp      k_write
	jp      k_seek


	.resw nmiEntry - $

	.dw ISR_keyboard

; BIOS-Routines ----------------------------------------------

.include "io.asm"
.include "interrupt.asm"
.include "sd.asm"
.include "drivers/ft240.asm"
.include "string.asm"
.include "math.asm"


; Cold start -------------------------------------------------

_coldStart:
	ld sp, sysStack

	;Set input and output to USB
	xor a
	call setOutput
	call setInput

	ld de, devfs_fsDriver
	ld a, 0
	call k_mount

	ld de, ttyName
	call k_open

	ld a, e
	ld (terminalFd), a
	ld de, 0c000h
	ld hl, 1
	call k_read

	ld a, (terminalFd)
	ld de, 0c000h
	ld hl, 1
	call k_write
;	ld a, (0c000h)
;	call putc


	call cli

ttyName:
	.asciiz "0:TTY0"



; Monitor ----------------------------------------------------

.include "monitor.asm"

.include "drive.asm"
.include "fs/file.asm"

; Filesystems
.include "fs/fat.asm"
.include "fs/devfs.asm"

; Device drivers
.include "drivers/sd.asm"
.include "drivers/ramdisk.asm"

.include "cli.asm"
