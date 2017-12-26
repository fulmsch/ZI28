#define coldStart  0x0000
#define putc       0x0008
#define getc       0x0010
#define syscall    0x0030
#define monitor    0x0038

//syscalls
#define SYS_open      0
#define SYS_close     1
#define SYS_read      2
#define SYS_write     3
#define SYS_seek      4
#define SYS_lseek     5
#define SYS_stat      6
#define SYS_fstat     7
#define SYS_readdir   8
#define SYS_dup       9
#define SYS_mount    10
#define SYS_unmount  11
#define SYS_unlink   12

//file system types
#define FS_DEV 0
#define FS_FAT 1

//file mode definition
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

//stat
#define STAT_NAME    0 ;13 bytes
#define STAT_ATTRIB 13 ;1 byte
#define STAT_SIZE   14 ;4 bytes
#define STAT_LEN    18

#define PATH_MAX 64
