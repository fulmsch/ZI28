#include <stdio.h>
#include <stdlib.h>

//int index;
char *inFileName;
char *outFileName;
char buffer[512];
int blocksize = 512;
char c;

int main(int argc, char **argv) {
	FILE *inFile = stdin;
	FILE *outFile = stdout;
	opterr = 0;

	while ((c = getopt(argc, argv, "hi:o:")) != -1) {
		switch (c) {
			case 'i':
				inFileName = optarg;
				break;
			case 'o':
				outFileName = optarg;
				break;
			case 'h':
				printf("Usage:\n\tDD [options]\n");
				printf("Options:\n");
				printf("\t-i\tInput file. Default: stdin.\n");
				printf("\t-o\tOutput file. Default: stdout.\n");
				return 0;
			case '?':
				if (optopt == 'i' || optopt == 'o') {
					fprintf (stderr, "%s: Option '-%c' requires an argument.\n", argv[0], optopt);
				} else if (isprint (optopt)) {
					fprintf (stderr, "%s: Unknown option '-%c'.\n", argv[0], optopt);
				} else {
					fprintf (stderr, "%s: Unknown option character '\\x%x'.\n", argv[0], optopt);
				}
				fprintf (stderr, "Type '%s -h' for more information.\n", argv[0]);
				return 1;
			default:
				abort ();
		}
	}

	//Try to open input/output files if specified
	if (inFileName && !(inFile = fopen(inFileName, "r"))) {
		fprintf(stderr, "%s: File '%s' could not be opened for reading.\n", argv[0], inFileName);
		return 1;
	}
	if (outFileName && !(outFile = fopen(outFileName, "w"))) {
		fprintf(stderr, "%s: File '%s' could not be opened for writing.\n", argv[0], outFileName);
		return 1;
	}

	while (1) {
		c = fgetc(inFile);
		if (c == EOF) {
			return 0;
		}
		fputc(c, outFile);
	}
}
