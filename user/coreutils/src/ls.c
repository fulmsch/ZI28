#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

//#define DEBUG
#define fail() fputs("Failure\n", stderr); return -1
int dirfd;
struct stat statBuf;

int main(int argc, char **argv) {
	int lflag = 0;
//	int bflag = 0;
//	char *cvalue = NULL;
	int index;
	int c;

	opterr = 0;

	while ((c = getopt(argc, argv, "l")) != -1)
		switch (c) {
			case 'l':
				lflag = 1;
				break;
			//case 'c':
			//	cvalue = optarg;
			//	break;
			case '?':
			//	if (optopt == 'c')
			//		fprintf (stderr, "Option -%c requires an argument.\n", optopt);
				if (isprint (optopt))
					fprintf (stderr, "Unknown option `-%c'.\n", optopt);
				else
					fprintf (stderr, "Unknown option character `\\x%x'.\n", optopt);
				return 1;
			default:
				abort ();
		}

	index = optind;


	if (argc - index == 0) {
		// No directory specified
		dirfd = open("./", (O_RDONLY), 0);
	} else {
		dirfd = open(argv[index], (O_RDONLY), 0);
	}

	if (dirfd == -1) {
		fail();
	}
#ifdef DEBUG
	else {
		printf("Fd: %d. Success\n", dirfd);
	}
#endif

	fstat(dirfd, &statBuf);

#ifdef DEBUG
	printf("mode: %d\n", statBuf.st_mode);
#endif

	if (!S_ISDIR(statBuf.st_mode)) {
		fputs("Error: not a directory\n", stderr);
		close(dirfd);
		return -1;
	}

	while (readdir(dirfd, &statBuf) == 0) {
		if (lflag) {
			if (S_ISREG(statBuf.st_mode)) {
				printf("%10ld %s\n", statBuf.st_size, statBuf.st_name);
			} else if (S_ISDIR(statBuf.st_mode)) {
				printf("DIR        %s\n", statBuf.st_name);
			} else if (S_ISBLK(statBuf.st_mode)) {
				printf("BLOCK      %s\n", statBuf.st_name);
			} else if (S_ISCHR(statBuf.st_mode)) {
				printf("CHAR       %s\n", statBuf.st_name);
			}
		}
		else {
			printf("%s\n", statBuf.st_name);
		}
	}

	if (close(dirfd) == -1) {
		fail();
	} else {
#ifdef DEBUG
		puts("Success");
#endif
	}
}
