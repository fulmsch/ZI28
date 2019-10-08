#ifndef INTERPRETER_H
#define INTERPRETER_H

#include <lua.h>

extern int quitRequest;
extern lua_State *globalLuaState;

void interpreter_init(char *configFile);
void interpreter_run(void);

#endif
