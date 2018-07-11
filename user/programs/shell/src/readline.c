#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include "readline.h"

#define MAX_LINE 256

struct {
	char buffer[MAX_LINE];
	int cursor;
	int length;
} line;

char *readline(const char *prompt)
{
	char c;
	int ret;

	line.cursor = 0;
	line.length = 0;
	memset(line.buffer, 0, MAX_LINE);

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
