#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <string.h>
#include <ctype.h>

#define BUFFER_SIZE 2048

//temporary, until malloc is implemented
char strBuffer[100];

int recursiveFlag, interactiveFlag, updateFlag;
int argIndex;
int ret;
struct stat destStat, srcStat;
char *src, *dest;
unsigned char buffer[BUFFER_SIZE];

void copy(char *src, char *dest, char *destDir);

int main(int argc, char **argv) {
	char c;
	opterr = 0;

	while ((c = getopt(argc, argv, "hrif")) != -1) {
		switch (c) {
			case 'h':
				printf("Usage:\n\tCP [-ri] SOURCE... DEST\n");
				printf("Options:\n");
				printf("\t-r\tRecursively copy directories and their contents.\n");
				printf("\t-i\tPrompt before overwriting.\n");
//				printf("\t-u\tOnly copy newer files.\n");
				printf("\t-h\tPrint this help message.\n");
				return 0;
			case 'r':
				//recursive
				recursiveFlag = 1;
				break;
			case 'i':
				//interactive
				interactiveFlag = 1;
				break;
//			case 'u':
//				//update
//				updateFlag = 1;
//				break;
			case '?':
				if (isprint (optopt)) {
					fprintf(stderr, "%s: Unknown option '-%c'.\n", argv[0], optopt);
				} else {
					fprintf(stderr, "%s: Unknown option character '\\x%x'.\n", argv[0], optopt);
				}
				fprintf(stderr, "Type '%s -h' for more information.\n", argv[0]);
				return 1;
			default:
				abort ();
		}
	}
	argIndex = optind;
	if (argc - argIndex < 1) {
		fprintf(stderr, "%s: Missing operand.\n", argv[0]);
		fprintf(stderr, "Type '%s -h' for more information.\n", argv[0]);
		return 1;
	}

	dest = argv[argc - 1];
	ret = stat(dest, &destStat);

	if ((!ret) && S_ISDIR(destStat.st_mode)) {
		//dest exists and is a directory
		//copy everything into dest
		for (; argIndex < (argc - 1); argIndex++) {
			//copy argv[argIndex] -> dest/argv[argIndex]
			(src = strrchr(argv[argIndex], '/')) ? ++src : (src = argv[argIndex]);
			copy(argv[argIndex], src, dest);
			//copy(argv[argIndex], argv[argIndex], dest);
		}
	} else if (argc - argIndex > 2) {
		//can't copy multiple things to a file
		fprintf(stderr, "%s: '%s' is not a directory.\n", argv[0], dest);
		abort();
	} else {
		//copy src -> dest
		copy(argv[argIndex], dest, NULL);
	}


	return 0;
}

void copy(char *src, char *dest, char *destDir) {
	int l, n, srcFd, destFd;
	char *destFile = dest;
	if (destDir) {
		//concatenate destDir and dest
		l = strlen(destDir) + strlen(dest) + 2; //reserve space for NULL and '/'
		printf("l = %d\n", l);
		if (l > 200) abort();
		//destFile = malloc(l); //TODO free
		destFile = strBuffer;
		strcpy(destFile, destDir);
		strcat(destFile, "/");
		strcat(destFile, dest);
		printf("destFile = %s\n", destFile);
	}
	//copy src -> destFile
	if (stat(src, &srcStat)) {
		fprintf(stderr, "CP: Can't copy '%s': no such file or directory.\n", src);
		return;
	}

	if (!stat(destFile, &destStat) && interactiveFlag) {
		printf("Overwrite '%s'?\n", destFile);
prompt: switch (getchar()) {
			case 'y':
			case 'Y':
			case 'j':
			case 'J':
				break;
			case 'n':
			case 'N':
				return;
			default:
				goto prompt;
		}
	}

	if (S_ISDIR(srcStat.st_mode)) {
//		if (!recursiveFlag) {
			fprintf(stderr, "CP: '%s' is a directory.\n", src);
			return;
//		}
	}

	if ((srcFd = open(src, O_RDONLY, 0)) == -1) {
		fprintf(stderr, "CP: Can't open '%s'.\n", src);
		return;
	}

	if ((destFd = open(destFile, O_WRONLY | O_TRUNC | O_CREAT, 0)) == -1) {
		close(srcFd);
		fprintf(stderr, "CP: Can't open '%s'.\n", destFile);
		return;
	}

	while (1) {
		n = read(srcFd, buffer, BUFFER_SIZE);
		if (!n) {
			close(srcFd);
			close(destFd);
			return;
		} else if (n == -1) {
			close(srcFd);
			close(destFd);
			fprintf(stderr, "CP: Can't read from '%s'.\n", src);
			return;
		}
		if (write(destFd, buffer, n) != n) {
			close(srcFd);
			close(destFd);
			fprintf(stderr, "CP: Can't write to '%s'.\n", destFile);
			return;
		}
	}
}
