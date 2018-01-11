IFNDEF OS_H
DEFINE OS_H

DEFC RST_coldStart = 0x0000
DEFC RST_putc      = 0x0008
DEFC RST_getc      = 0x0010
DEFC RST_strerror  = 0x0028
DEFC RST_syscall   = 0x0030
DEFC RST_monitor   = 0x0038

; syscalls
DEFC SYS_open    =  0
DEFC SYS_close   =  1
DEFC SYS_read    =  2
DEFC SYS_write   =  3
DEFC SYS_seek    =  4
DEFC SYS_lseek   =  5
DEFC SYS_stat    =  6
DEFC SYS_fstat   =  7
DEFC SYS_readdir =  8
DEFC SYS_dup     =  9
DEFC SYS_mount   = 10
DEFC SYS_unmount = 11
DEFC SYS_unlink  = 12
DEFC SYS_breq    = 13
DEFC SYS_bfree   = 14
DEFC SYS_bsel    = 15

; file system types
DEFC FS_DEV = 0
DEFC FS_FAT = 1

; file mode definition
DEFC M_READ   = 0x01
DEFC M_WRITE  = 0x02
DEFC M_REG    = 0x04
DEFC M_DIR    = 0x08
DEFC M_CHAR   = 0x10
DEFC M_BLOCK  = 0x20
DEFC M_APPEND = 0x40

DEFC M_READ_BIT   = 0
DEFC M_WRITE_BIT  = 1
DEFC M_REG_BIT    = 2
DEFC M_DIR_BIT    = 3
DEFC M_CHAR_BIT   = 4
DEFC M_BLOCK_BIT  = 5
DEFC M_APPEND_BIT = 6

; stat
;TODO z80asm struct
DEFC STAT_NAME    =    0 ;13 bytes
DEFC STAT_ATTRIB  =   13 ;1 byte
DEFC STAT_SIZE    =   14 ;4 bytes
DEFC STAT_LEN     =   18

DEFC SP_READ      = 0x01 ;read permission
DEFC SP_WRITE     = 0x02 ;write permission
DEFC ST_REG       = 0x04 ;regular file
DEFC ST_DIR       = 0x08 ;directory
DEFC ST_CHAR      = 0x10 ;character device
DEFC ST_BLOCK     = 0x20 ;block device

DEFC SP_READ_BIT  =    0 ;read permission
DEFC SP_WRITE_BIT =    1 ;write permission
DEFC ST_REG_BIT   =    2 ;regular file
DEFC ST_DIR_BIT   =    3 ;directory
DEFC ST_CHAR_BIT  =    4 ;character device
DEFC ST_BLOCK_BIT =    5 ;block device


DEFC PATH_MAX = 64

DEFC SEEK_SET = 0
DEFC SEEK_CUR = 1
DEFC SEEK_END = 2

DEFC STDIN_FILENO  = 0
DEFC STDOUT_FILENO = 1
DEFC STDERR_FILENO = 2

;open flags
DEFC O_RDONLY        = 0x01
DEFC O_WRONLY        = 0x02
DEFC O_RDWR          = 0x04
DEFC O_APPEND        = 0x08
DEFC O_DIRECTORY     = 0x10
DEFC O_TRUNC         = 0x20 ;unused
DEFC O_CREAT         = 0x40
DEFC O_EXCL          = 0x80

DEFC O_RDONLY_BIT    =    0
DEFC O_WRONLY_BIT    =    1
DEFC O_RDWR_BIT      =    2
DEFC O_APPEND_BIT    =    3
DEFC O_DIRECTORY_BIT =    4
DEFC O_TRUNC_BIT     =    5 ;unused
DEFC O_CREAT_BIT     =    6
DEFC O_EXCL_BIT      =    7

ENDIF
