;TODO move to more appropriate header
#define STDIN_FILENO  0
#define STDOUT_FILENO 1
#define STDERR_FILENO 2

;mode definition
#define M_READ  0
#define M_WRITE 1
#define M_REG   2
#define M_DIR   3
#define M_CHAR  4
#define M_BLOCK 5

;flags for open
#define O_RDONLY 0
#define O_WRONLY 1
#define O_RDWR   2

;stat
#define STAT_NAME    0 ;13 bytes
#define STAT_ATTRIB 13 ;1 byte
#define STAT_SIZE   14 ;4 bytes
#define STAT_LEN    18

#define SP_READ  0 ;read permission
#define SP_WRITE 1 ;write permission
#define ST_REG   2 ;regular file
#define ST_DIR   3 ;directory
#define ST_CHAR  4 ;character device
#define ST_BLOCK 5 ;block device
