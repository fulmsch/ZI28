/*
 *  Just a placeholder
 *
 *	$Id: unistd.h,v 1.3 2013-06-26 13:34:42 stefano Exp $
 */

#ifndef __UNISTD_H__
#define __UNISTD_H__


#define SEEK_SET 0
#define SEEK_CUR 1
#define SEEK_END 2

#define STDIN_FILENO  0
#define STDOUT_FILENO 1
#define STDERR_FILENO 2


#ifndef __NAKEN_ASM
#include <sys/compiler.h>
#include <sys/types.h>

extern char *environ[];
#define isatty(fd) fchkstd(fd)
#define unlink(a) remove(a)
#endif

#endif
