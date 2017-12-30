#ifndef __SYS_STAT_H__
#define __SYS_STAT_H__

#include <sys/os.h>
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

#define S_IFMT (ST_REG | ST_DIR | ST_CHAR | ST_BLOCK)

#define S_IFBLK  ST_BLOCK
#define S_IFCHR  ST_CHAR
#define S_IFIFO  0xFF
#define S_IFREG  ST_REG
#define S_IFDIR  ST_DIR
#define S_IFLNK  0xFF
#define S_IFSOCK 0xFF

#endif
