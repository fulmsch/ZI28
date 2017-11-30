#ifndef __SYS_STAT_H__
#define __SYS_STAT_H__

#define SP_READ  0x01 //;read permission
#define SP_WRITE 0x02 //;write permission
#define ST_REG   0x04 //;regular file
#define ST_DIR   0x08 //;directory
#define ST_CHAR  0x10 //;character device
#define ST_BLOCK 0x20 //;block device

#define SP_READ_BIT  0 //;read permission
#define SP_WRITE_BIT 1 //;write permission
#define ST_REG_BIT   2 //;regular file
#define ST_DIR_BIT   3 //;directory
#define ST_CHAR_BIT  4 //;character device
#define ST_BLOCK_BIT 5 //;block device

#ifndef __NAKEN_ASM

#include <sys/types.h>

struct stat {
	char st_name[13];
	mode_t st_mode;
	off_t st_size;
};

extern int __LIB__ __CALLEE__ stat(char *filename, struct stat *buf);
extern int __LIB__ __CALLEE__ fstat(int fd, struct stat *buf);
extern int __LIB__ __CALLEE__ readdir(int dirfd, struct stat *buf);

extern int __LIB__  mkdir(char *dirname);
#define mkdir(a,b) mkdir(a)

#define S_ISREG(m)	((m) & ST_REG)
#define S_ISDIR(m)	((m) & ST_DIR)
#define S_ISCHR(m)	((m) & ST_CHAR)
#define S_ISBLK(m)	((m) & ST_BLOCK)

#endif
#endif
