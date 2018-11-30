#ifndef COMMAND_H
#define COMMAND_H

#include <lua.h>

/* Try to interpret string on top of stack as emulator command. Return 0 if unsuccessful. */
int asCommand(lua_State *L);

#endif
