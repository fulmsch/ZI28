#ifndef __SYS_STAT_H__
#define __SYS_STAT_H__


#define SP_READ  0 ;read permission
#define SP_WRITE 1 ;write permission
#define ST_REG   2 ;regular file
#define ST_DIR   3 ;directory
#define ST_CHAR  4 ;character device
#define ST_BLOCK 5 ;block device

#ifndef __NAKEN_ASM

struct stat {
	char st_name[13];
	unsigned char st_attrib;
	long st_size;
};

extern int __LIB__ __CALLEE__ stat(char *filename, struct stat *buf);
extern int __LIB__ __CALLEE__ fstat(int fd, struct stat *buf);
extern int __LIB__ __CALLEE__ readdir(int dirfd, struct stat *buf);

extern int __LIB__  mkdir(char *dirname);
#define mkdir(a,b) mkdir(a)

#define S_ISREG(m)	((m) & (1 << ST_REG))
#define S_ISDIR(m)	((m) & (1 << ST_DIR))
#define S_ISCHR(m)	((m) & (1 << ST_CHR))
#define S_ISBLK(m)	((m) & (1 << ST_BLK))

#endif
#endif
