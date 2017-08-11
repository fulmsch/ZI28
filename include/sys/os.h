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
#define SYS_chmain   11

//file mode definition
#define M_READ  0
#define M_WRITE 1
#define M_REG   2
#define M_DIR   3
#define M_CHAR  4
#define M_BLOCK 5

//stat
#define STAT_NAME    0 ;13 bytes
#define STAT_ATTRIB 13 ;1 byte
#define STAT_SIZE   14 ;4 bytes
#define STAT_LEN    18

//seek modes
#define K_SEEK_SET  0
#define K_SEEK_PCUR 1
#define K_SEEK_NCUR 2
#define K_SEEK_END  3

#define PATH_MAX 64
