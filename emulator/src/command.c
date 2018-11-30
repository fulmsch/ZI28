#include <string.h>
#include <stdio.h>

#include "command.h"
#include "interpreter.h"

struct command {
	char *name;
	void (*function)(void);
};

static void cmd_step(void);
static void cmd_quit(void);

static struct command commandTable[] = {
	{"s",    cmd_step},
	{"step", cmd_step},
	{"q",    cmd_quit},
	{"quit", cmd_quit},
};

int asCommand(lua_State *L)
{
	void (*f)(void) = NULL;
	static void (*prevf)(void) = NULL;
	const char *line = lua_tostring(L, -1);
	if (line[0] == '\0') {
		return prevf != NULL ? prevf(), 1 : 0;
	}
	for (int i = 0; i < sizeof(commandTable)/sizeof(struct command); i++) {
		if (!strcmp(commandTable[i].name, line)) {
			f = commandTable[i].function;
			break;
		}
	}
	prevf = f;
	return f != NULL ? f(), 1 : 0;
}

static void cmd_step(void)
{
	printf("Stepping\n");
	return;
}

static void cmd_quit(void)
{
	quitRequest = 1;
	return;
}
