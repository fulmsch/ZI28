#include <stdio.h>
#include <stdlib.h>

#define MAX_LINE 256

struct {
	char buffer[MAX_LINE];
	int cursor;
	int length;
} line;



static char *handleline(const char *prompt);
static int ret;

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
	while (handleline("> ") != 0) {
		ret = fork();
		printf("%d\n", ret);
		if (ret == 0) {
			//child
			printf("Successful fork\n");
			execv(line.buffer, NULL);
			printf("error\n");
		} else if (ret == -1) {
			//error
			printf("Error forking\n");
		} else {
			printf("Returned\n");
		}
	}
}


char *handleline(const char *prompt)
{
	char c;
	int ret;

	line.cursor = 0;
	line.length = 0;

	if (prompt != NULL) printf("%s", prompt);

	while (1) {
		ret = read(STDIN_FILENO, &c, 1);
		if (ret == 0) {
			//EOF
			return NULL;
		} else {
			//Error
		}
		switch (c) {
			case 0x08:
				//Backspace
				if (line.cursor == 0) break;
				line.cursor--;
				line.length--;
				printf("\b \b");
				break;
			case 0x0a:
				write(STDOUT_FILENO, &c, 1);
				line.buffer[line.cursor] = 0;
				//printf("%s\n", line.buffer);
				return line.buffer;
			default:
				if (c >= ' ' && c <= '~') {
					if (++line.length >= MAX_LINE - 1) return NULL;
					line.buffer[line.cursor++] = c;
					write(STDOUT_FILENO, &c, 1);
				}
				break;
		}
	}
}
