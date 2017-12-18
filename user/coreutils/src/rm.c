#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>

int recursiveFlag, interactiveFlag, forceFlag;
int index;
int ret;
struct stat statBuf;

int main(int argc, char **argv) {
	char c;
	opterr = 0;

	while ((c = getopt(argc, argv, "hrif")) != -1) {
		switch (c) {
			case 'h':
				printf("Usage:\n\tRM [-irf] FILE...\n");
				printf("Options:\n");
				printf("\t-f\tIgnore nonexistent files, never prompt.\n");
				printf("\t-i\tPrompt before every removal.\n");
				printf("\t-r\tRecursively remove directories and their contents.\n");
				printf("\t-h\tPrint this help message.\n");
				return 0;
			case 'r':
				//recursive
				recursiveFlag = 1;
				break;
			case 'i':
				//interactive
				forceFlag = 0;
				interactiveFlag = 1;
				break;
			case 'f':
				//force
				interactiveFlag = 0;
				forceFlag = 1;
				break;
			case '?':
				if (isprint (optopt)) {
					fprintf(stderr, "%s: Unknown option '-%c'.\n", argv[0], optopt);
				} else {
					fprintf(stderr, "%s: Unknown option character '\\x%x'.\n", argv[0], optopt);
				}
				fprintf(stderr, "Type 'RM -h' for more information.\n", argv[0]);
				return 1;
			default:
				abort ();
		}
	}
	index = optind;
	if (index == argc) {
		fprintf(stderr, "%s: Missing operand.\n", argv[0], optopt);
		fprintf(stderr, "Type 'RM -h' for more information.\n", argv[0]);
		return 1;
	}

	for (; index < argc; index++) {
		ret = stat(argv[index], &statBuf);
		if (ret) {
			fprintf(stderr,
			        "%s: Can't remove '%s': no such file or directory.\n",
			        argv[0], argv[index]);
			continue;
		}
		if (S_ISDIR(statBuf.st_mode)) {
			fprintf(stderr,
			        "%s: '%s' is a directory.\n",
			        argv[0], argv[index]);
			continue;
		}
		ret = unlink(argv[index]);
		if (ret) {
			//TODO error message according to errno
			fprintf(stderr,
			        "%s: Can't remove '%s': unknown error.\n",
			        argv[0], argv[index]);
		}
	}

	return 0;
}
