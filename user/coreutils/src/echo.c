#include <stdio.h>
#include <stdlib.h>

int index;
int noNewLines;
char c;

int main(int argc, char **argv) {
	opterr = 0;

	while ((c = getopt(argc, argv, "hn")) != -1) {
		switch (c) {
			case 'n':
				noNewLines = 1;
				break;
			case 'h':
				printf("Usage:\n\tECHO [options] [string ...]\n");
				printf("Options:\n");
				printf("\t-n\tDo not output the trailing newline.\n");
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

	index = optind;

	for (; index < argc; index++) {
		printf((index == argc - 1) ? "%s" : "%s ", argv[index]);
	}
	if (!noNewLines) printf("\n");
}
