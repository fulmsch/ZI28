#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include "interpreter.h"
#include "builtins.h"

static int ret;
//static char *start;
static char *curr;
//static int argCounter;
//static char *arguments[16];
static int i;

static commandParam_t param;
static char *arguments[16];

void interpret(char* line)
{
	param.argv = arguments;
	param.argc = 0;
	param.inFile = 0;
	param.outFile = 0;

//	start = line;
	curr = line;
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
				param.argv[param.argc] = curr;
				param.argc++;
				while (*curr != ' ' && *curr != '\t' && *curr != 0) curr++;
				*curr = 0;
				curr ++;
				break;
		}
		//TODO limit amount of arguments
	}

	if (param.argc == 0) return;

	param.argv[param.argc] = 0;

	/*
	printf("Interpreting the following line\n%s\n", line);
	for (i = 0; i < param.argc; i++) {
		printf("%s\n", param.argv[i]);
	}
	*/

	//Check if command is a builtin
	// cd, clear, echo, exit, false, help, monitor, pwd, true
	switch (param.argv[0][0]) {
		case 'c':
			if (!strcmp(param.argv[0], "cd")) {
				builtin_cd(&param);
				return;
			} else if (!strcmp(param.argv[0], "clear")) {
				builtin_clear(&param);
				return;
			}
			break;
		case 'e':
			if (!strcmp(param.argv[0], "echo")) {
				builtin_echo(&param);
				return;
			} else if (!strcmp(param.argv[0], "exit")) {
				builtin_exit(&param);
				return;
			}
			break;
		case 'f':
			if (!strcmp(param.argv[0], "false")) {
				builtin_false(&param);
				return;
			}
			break;
		case 'h':
			if (!strcmp(param.argv[0], "help")) {
				builtin_help(&param);
				return;
			}
			break;
		case 'm':
			if (!strcmp(param.argv[0], "monitor")) {
				builtin_monitor(&param);
				return;
			}
			break;
		case 'p':
			if (!strcmp(param.argv[0], "pwd")) {
				builtin_pwd(&param);
				return;
			}
			break;
		case 't':
			if (!strcmp(param.argv[0], "true")) {
				builtin_true(&param);
				return;
			}
			break;
		default:
			break;
	}


	ret = fork();
	//printf("%d\n", ret);
	if (ret == 0) {
		//child
		//printf("Successful fork\n");
		execv(param.argv[0], param.argv);
		printf("error\n");
	} else if (ret == -1) {
		//error
		printf("Error forking\n");
	}
}
