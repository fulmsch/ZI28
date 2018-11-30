#ifndef LUAINTERFACE_H
#define LUAINTERFACE_H

#include <lua.h>

#include "emulator.h"

struct memPointer {
	unsigned int address;
	unsigned int size;
};

void setupLuaEnv(lua_State *L);
int evaluateCondition(lua_State *L, struct breakpoint *bp);

#endif
