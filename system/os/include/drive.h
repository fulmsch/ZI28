IFNDEF DRIVE_H
DEFINE DRIVE_H

;*********** Drive Table ********************

;TODO change to z80asm struct
DEFC driveTableChild    = 0                          ;1 byte
DEFC driveTableSibling  = driveTableChild + 1        ;1 byte
DEFC driveTableDevfd    = driveTableSibling + 1      ;1 byte
DEFC driveTableFsdriver = driveTableDevfd + 1        ;2 bytes
                                                      ;-------
                                                ;Total 5 bytes
DEFC driveTableFsData   = driveTableFsdriver + 2 ;Max 27 bytes

DEFC fs_init    =  0
DEFC fs_open    =  2
DEFC fs_close   =  4 ;not used yet
DEFC fs_readdir =  6
DEFC fs_fstat   =  8
DEFC fs_unlink  = 10

ENDIF
