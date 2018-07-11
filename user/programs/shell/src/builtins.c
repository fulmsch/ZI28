#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/os.h>
#include "builtins.h"

void builtin_cd      (commandParam_t *param)
{
	switch (param->argc) {
		case 1:
			chdir("/HOME");
			return;
		case 2:
			chdir(param->argv[1]);
			return;
		default:
			printf("Too many arguments.\n");
			return;
	}
}

void builtin_clear   (commandParam_t *param)
{
	printf("\x1b[2J\x1b[H");
}

void builtin_echo    (commandParam_t *param)
{
	int i;
	if (param->argc == 1) {
		printf("\n");
		return;
	}
	for (i = 1; i < param->argc - 1; i++) {
		printf("%s ", param->argv[i]);
	}
	printf("%s\n", param->argv[param->argc - 1]);
}

void builtin_exit    (commandParam_t *param)
{
	exit(0);
}

void builtin_false   (commandParam_t *param)
{
}

void builtin_help    (commandParam_t *param)
{
}

void builtin_monitor (commandParam_t *param)
{
}

void builtin_pwd     (commandParam_t *param)
{
	char cwd[PATH_MAX];
	if (getcwd(cwd) == 0) {
		//error
		return;
	}
	printf("%s\n", cwd);
}

void builtin_true    (commandParam_t *param)
{
}
