#include <string.h>
#include <stdio.h>

#include "command.h"
#include "interpreter.h"
#include "emulator.h"

struct command {
	char *name;
	void (*function)(lua_State *);
};

static void cmd_step(lua_State *L);
static void cmd_quit(lua_State *L);

static struct command commandTable[] = {
	{"s",    cmd_step},
	{"step", cmd_step},
	{"q",    cmd_quit},
	{"quit", cmd_quit},
};

int asCommand(lua_State *L)
{
	void (*f)(lua_State *) = NULL;
	static void (*prevf)(lua_State *) = NULL;
	const char *line = lua_tostring(L, -1);
	if (line[0] == '\0') {
		return prevf != NULL ? prevf(L), 1 : 0;
	}
	for (int i = 0; i < sizeof(commandTable)/sizeof(struct command); i++) {
		if (!strcmp(commandTable[i].name, line)) {
			f = commandTable[i].function;
			break;
		}
	}
	prevf = f;
	return f != NULL ? f(L), 1 : 0;
}

static void cmd_step(lua_State *L)
{
	emu_run(L, EMU_STEP, 1);
	return;
}

static void cmd_quit(lua_State *L)
{
	quitRequest = 1;
	return;
}
