#include <stdio.h>
#include "interpreter.h"

static int ret;
//static char *start;
static char *curr;
static int argCounter;
static char *arguments[16];
static int i;

void interpret(char* line)
{
	printf("Interpreting the following line\n%s\n", line);

//	start = line;
	curr = line;
	argCounter = 0;
	while (*curr != 0) {
		switch (*curr) {
			case ' ':
			case '\t':
				curr++;
				break;
			case '>':
			case '<':
			case '|':
			case ';':
			default:
				//normal argument
				arguments[argCounter++] = curr;
				while (*curr != ' ' && *curr != '\t' && *curr != 0) curr++;
				*curr = 0;
				curr ++;
				break;
		}
	}

	if (argCounter == 0) return;

	arguments[argCounter] = 0;

	for (i = 0; i < argCounter; i++) {
		printf("%s\n", arguments[i]);
	}



	ret = fork();
	printf("%d\n", ret);
	if (ret == 0) {
		//child
		printf("Successful fork\n");
		execv(arguments[0], arguments);
		printf("error\n");
	} else if (ret == -1) {
		//error
		printf("Error forking\n");
	} else {
		printf("Returned\n");
	}
}
