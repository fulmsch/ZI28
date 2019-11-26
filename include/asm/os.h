#define RST_coldStart 0x0000
#define RST_putc      0x0008
#define RST_getc      0x0010
#define RST_strerror  0x0028
#define RST_syscall   0x0030
#define RST_monitor   0x0038

#define MEM_user      0x8100
#define MEM_user_top  0xC000

; syscalls
#define SYS_open     0
#define SYS_close    1
#define SYS_read     2
#define SYS_write    3
#define SYS_seek     4
#define SYS_lseek    5
#define SYS_stat     6
#define SYS_fstat    7
#define SYS_readdir  8
#define SYS_dup      9
#define SYS_mount   10
#define SYS_unmount 11
#define SYS_unlink  12
#define SYS_bsel    13
#define SYS_execv   14
#define SYS_exit    15
#define SYS_chdir   16
#define SYS_getcwd  17

; file system types
#define FS_DEV 0
#define FS_FAT 1

; file mode definition
#define M_READ   0x01
#define M_WRITE  0x02
#define M_REG    0x04
#define M_DIR    0x08
#define M_CHAR   0x10
#define M_BLOCK  0x20
#define M_APPEND 0x40

#define M_READ_BIT   0
#define M_WRITE_BIT  1
#define M_REG_BIT    2
#define M_DIR_BIT    3
#define M_CHAR_BIT   4
#define M_BLOCK_BIT  5
#define M_APPEND_BIT 6

; stat
;TODO z80asm struct
#define STAT_NAME       0 ;13 bytes
#define STAT_ATTRIB    13 ;1 byte
#define STAT_SIZE      14 ;4 bytes
#define STAT_LEN       18

#define SP_READ      0x01 ;read permission
#define SP_WRITE     0x02 ;write permission
#define ST_REG       0x04 ;regular file
#define ST_DIR       0x08 ;directory
#define ST_CHAR      0x10 ;character device
#define ST_BLOCK     0x20 ;block device

#define SP_READ_BIT     0 ;read permission
#define SP_WRITE_BIT    1 ;write permission
#define ST_REG_BIT      2 ;regular file
#define ST_DIR_BIT      3 ;directory
#define ST_CHAR_BIT     4 ;character device
#define ST_BLOCK_BIT    5 ;block device


#define PATH_MAX 64

#define SEEK_SET 0
#define SEEK_CUR 1
#define SEEK_END 2

#define STDIN_FILENO  0
#define STDOUT_FILENO 1
#define STDERR_FILENO 2

;open flags
#define O_RDONLY        0x01
#define O_WRONLY        0x02
#define O_RDWR          0x04
#define O_APPEND        0x08
#define O_DIRECTORY     0x10
#define O_TRUNC         0x20 ;unused
#define O_CREAT         0x40
#define O_EXCL          0x80

#define O_RDONLY_BIT       0
#define O_WRONLY_BIT       1
#define O_RDWR_BIT         2
#define O_APPEND_BIT       3
#define O_DIRECTORY_BIT    4
#define O_TRUNC_BIT        5 ;unused
#define O_CREAT_BIT        6
#define O_EXCL_BIT         7
