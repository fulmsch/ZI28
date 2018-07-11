#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/os.h>
#include "readline.h"
#include "interpreter.h"


static char *line;
static char *prompt(void);

int main(int argc, char **argv)
{
	int index;
	char c;
	opterr = 0;

	while ((c = getopt(argc, argv, "h")) != -1) {
		switch (c) {
			case 'h':
				printf("Usage:\n\tSH [options] [string ...]\n");
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
	printf("\n");
	while ((line = readline(prompt())) != 0) {
		interpret(line);
	}
}

static char *prompt()
{
	static char promptStr[PATH_MAX + 16];
	char cwd[PATH_MAX];
	getcwd(cwd);
	sprintf(promptStr, "\x1b[36m%s\x1b[m$ ", cwd);
	return promptStr;
}
