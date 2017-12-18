//#include <fcntl.h>
#include <string.h>
#include <stdio.h>

//#define DEBUG
#define fail() fputs("Failure\n", stderr); return -1

FILE *curFile;
int i;

void readfile(FILE *);

int main(int argc, char **argv) {
	if (argc == 1) {
		//no files specified, read from stdin and return
		readfile(stdin);
		putchar('\n');
		return 0;
	}

	for (i = 1; i < argc; i++) {
		if (!strcmp(argv[i], "-")) {
			readfile(stdin);
			putchar('\n');
		} else {
			curFile = fopen(argv[i], "r");
			if (!curFile) {
				fprintf(stderr, "%s: File '%s' could not be opened for reading.\n", argv[0], argv[i]);
			} else {
				readfile(curFile);
			}
		}
	}
	return 0;
}

void readfile(FILE *file) {
	char c;
	while (1) {
		c = fgetc(file);
		if (c == EOF) {
			clearerr(file);
			return;
		}
		putchar(c);
	}
}
