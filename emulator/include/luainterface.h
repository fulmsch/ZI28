#ifndef LUAINTERFACE_H
#define LUAINTERFACE_H

#include <lua.h>

struct memPointer {
	unsigned int address;
	unsigned int size;
};

void setupLuaEnv(lua_State *L);

#endif
