/*
 *  Just a placeholder
 *
 *	$Id: unistd.h,v 1.3 2013-06-26 13:34:42 stefano Exp $
 */

#ifndef __UNISTD_H__
#define __UNISTD_H__

#include <sys/os.h>
#include <sys/compiler.h>
#include <sys/types.h>

extern char *environ[];
#define isatty(fd) fchkstd(fd)
#define unlink(a) remove(a)

extern int __LIB__ __CALLEE__ execv(char *path, char **argv);
extern int __LIB__ fork(void);
extern int __LIB__ __FASTCALL__ chdir(char *path);
extern char __LIB__ __FASTCALL__ *getcwd(char *buf);

/*** getopt ***/
extern int  __LIB__  getopt (int, char **, char *);
extern char *optarg;                      /* getopt(3) external variables */
extern int opterr;
extern int optind;
extern int optopt;
extern int optreset;

#endif
