ORG 0x0000

EXTERN _coldStart, _putc, _getc, _warmStart


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
	jp      _warmStart   ;RST 0x18
	DEFB    0x00
	jp      0x00         ;CALL 0x1C
	DEFB    0x00
	jp      0x00         ;RST 0x20
	DEFB    0x00
	jp      0x00         ;CALL 0x24
	DEFB    0x00
	jp      0x00         ;RST 0x28
	DEFB    0x00
	jp      0x00         ;CALL 0x2C
	DEFB    0x00
	jp      0x00         ;RST 0x30
	DEFB    0x00
	jp      0x00         ;CALL 0x34
	DEFB    0x00
	jp      0x00         ;RST 0x38

SECTION rom_code
SECTION rom_data


SECTION RAM
	org 0x4000
