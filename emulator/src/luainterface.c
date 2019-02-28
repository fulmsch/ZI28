#include <string.h>
#include <lua.h>
#include <lauxlib.h>

#include "luainterface.h"
#include "emulator.h"
#include "interpreter.h"


static int breakpointMetatable;

static int luaF_breakpoint_index(lua_State *L)
{
	//Arguments: table, key
	lua_settop(L, 2);
	struct breakpoint *bp = lua_touserdata(L, 1);
	const char *key = lua_tostring(L, 2);
	if (!strcmp("pointer", key)) {
		lua_getglobal(L, "ptr");
		lua_pushinteger(L, bp->address);
		lua_pushinteger(L, bp->size);
		lua_call(L, 2, 1);
	} else if (!strcmp("type", key)) {
		switch (bp->type) {
			case TYPE_BREAK:
				lua_pushstring(L, "break"); break;
			case TYPE_TRACE:
				lua_pushstring(L, "trace"); break;
			case TYPE_WATCH:
				lua_pushstring(L, "watch"); break;
			default:
				lua_pushnil(L); break;
		}
	} else if (!strcmp("condition", key)) {
		lua_rawgeti(L, LUA_REGISTRYINDEX, bp->condition);
	} else if (!strcmp("icount", key)) {
		lua_pushinteger(L, bp->icount);
	} else if (!strcmp("ecount", key)) {
		lua_pushinteger(L, bp->ecount);
	} else {
		lua_pushnil(L);
	}
	return 1;
}

static int luaF_readonly(lua_State *L)
{
	return 0;
}

static void createBreakpointTable(lua_State *L)
{
	lua_newtable(L);
	lua_newtable(L); //metatable
	lua_pushcfunction(L, luaF_readonly);
	lua_setfield(L, -2, "__newindex");
	lua_setmetatable(L, -2);
	lua_setglobal(L, "breakpoints");
}


static int luaF_run(lua_State *L);
static int luaF_step(lua_State *L);
static int luaF_next(lua_State *L);
static int luaF_finish(lua_State *L);
static int luaF_reset(lua_State *L);
static int luaF_quit(lua_State *L);
static int luaF_newBreakpoint(lua_State *L);
static int luaF_newTracepoint(lua_State *L);
static int luaF_newWatchpoint(lua_State *L);
static int luaF_addmodule(lua_State *L);

static int luaF_continue(lua_State *L);
static int luaF_advance(lua_State *L);
static int luaF_out(lua_State *L);

static int luaF_ptr(lua_State *L);

static luaL_Reg luaFunctionTable[] = {
	{"run",        luaF_run          },
	{"s",          luaF_step         },
	{"step",       luaF_step         },
	{"n",          luaF_next         },
	{"next",       luaF_next         },
	{"f",          luaF_finish       },
	{"finish",     luaF_finish       },
	{"c",          luaF_continue     },
	{"continue",   luaF_continue     },
	{"a",          luaF_advance      },
	{"advance",    luaF_advance      },
	{"o",          luaF_out          },
	{"out",        luaF_out          },
	{"reset",      luaF_reset        },
	{"q",          luaF_quit         },
	{"quit",       luaF_quit         },
	{"ptr",        luaF_ptr          },
	{"breakpoint", luaF_newBreakpoint},
	{"tracepoint", luaF_newTracepoint},
	{"watchpoint", luaF_newWatchpoint},
	{"addmodule",  luaF_addmodule    },
};

void setupLuaEnv(lua_State *L)
{
	lua_getglobal(L, "_G");
	luaL_setfuncs(L, luaFunctionTable, 0);
	lua_pop(L, 1);

	//Global breakpoint table
	createBreakpointTable(L);
	lua_createtable(L, 0, 2);
	lua_pushcfunction(L, luaF_breakpoint_index);
	lua_setfield(L, -2, "__index");
	lua_pushcfunction(L, luaF_readonly);
	lua_setfield(L, -2, "__newindex");
	breakpointMetatable = luaL_ref(L, LUA_REGISTRYINDEX);

	//Module paths
	lua_getglobal(L, "package");
	lua_getfield(L, -1, "cpath");
	lua_pushstring(L, ";./emulator/modules/?/?.so");
	lua_concat(L, 2);
	lua_setfield(L, -2, "cpath");

	lua_getfield(L, -1, "path");
	lua_pushstring(L, ";./emulator/modules/?/?.lua");
	lua_concat(L, 2);
	lua_setfield(L, -2, "path");
	lua_pop(L, 1);


	lua_createtable(L, 8, 0);
	lua_setglobal(L, "modules");
}

static int getMemPointer(lua_State *L, int index, struct memPointer *ptr)
{
	int isnum;
	lua_Integer size, address;

	//Check if the object at the index is a table with valid values for "address" and "size"
	if (lua_type(L, index) != LUA_TTABLE) {
		return -1;
	}
	lua_getfield(L, index, "address");
	address = lua_tointegerx(L, -1, &isnum);
	lua_pop(L, 1);
	if (!isnum || address < 0 || address > 0xFFFF) return -1;
	lua_getfield(L, index, "size");
	size = lua_tointegerx(L, -1, &isnum);
	lua_pop(L, 1);
	if (!isnum || size < 1 || size > 0xFFFF) return -1;
	ptr->address = address;
	ptr->size = size;
	return 0;
}

static int luaF_reset(lua_State *L)
{
	emu_reset();
	return 0;
}

static int luaF_run(lua_State *L)
{
	emu_run(L, EMU_RUN, 0);
	return 0;
}

static int luaF_step(lua_State *L)
{
	int steps, isnum;
	if(lua_gettop(L) <= 0) steps = 1;
	else {
		steps = lua_tointegerx(L, 1, &isnum);
		if(!isnum || steps < 1) steps = 1;
	}
	emu_run(L, EMU_STEP, steps);
	return 0;
}

static int luaF_next(lua_State *L)
{
	int steps, isnum;
	if(lua_gettop(L) <= 0) steps = 1;
	else {
		steps = lua_tointegerx(L, 1, &isnum);
		if(!isnum || steps < 1) steps = 1;
	}
	emu_run(L, EMU_NEXT, steps);
	return 0;
}

static int luaF_finish(lua_State *L)
{
	emu_run(L, EMU_FINISH, 0);
	return 0;
}

static int luaF_continue(lua_State *L)
{
	int ignorecount = luaL_optinteger(L, 1, 1);
	emu_run(L, EMU_CONTINUE, ignorecount);
	return 0;
}

static int luaF_advance(lua_State *L)
{
	int address = -1;
	if (lua_type(L, 1) == LUA_TTABLE) {
		struct memPointer pointer;
		if (getMemPointer(L, 1, &pointer) == 0) {
			address = pointer.address;
		}
	} else {
		address = luaL_optinteger(L, 1, -1);
	}

	if (address < 0 || address > 0xffff) {
		return luaL_error(L, "invalid argument");
	}

	emu_run(L, EMU_ADVANCE, address);

	return 0;
}

static int luaF_out(lua_State *L)
{
	int address = -1;
	if (lua_gettop(L) > 0) {
		if (lua_type(L, 1) == LUA_TTABLE) {
			struct memPointer pointer;
			if (getMemPointer(L, 1, &pointer) == 0) {
				address = pointer.address;
			}
		} else {
			address = luaL_optinteger(L, 1, -1);
		}

		if (address < 0 || address > 0xffff) {
			return luaL_error(L, "invalid argument");
		}
	}

	emu_run(L, EMU_OUT, address);

	return 0;
}

static int luaF_quit(lua_State *L)
{
	quitRequest = 1;
	return 0;
}

static int luaF_ptr_index(lua_State *L)
{
	//Arguments: table, key
	const char *key = lua_tostring(L, 2);
	if (!strcmp("a", key)) {
		lua_getfield(L, 1, "address");
	} else if (!strcmp("s", key)) {
		lua_getfield(L, 1, "size");
	} else if (!strcmp("v", key) || !strcmp("value", key)) {
	} else {
		lua_pushnil(L);
	}
	return 1;
}

static int luaF_ptr_newindex(lua_State *L)
{
	//Arguments: table, key, value
	const char *key = lua_tostring(L, 2);
	if (!strcmp("a", key)) {
		lua_setfield(L, 1, "address");
	} else if (!strcmp("s", key)) {
		lua_setfield(L, 1, "size");
	} else if (!strcmp("v", key) || !strcmp("value", key)) {
	}
	return 0;
}

static int luaF_ptr(lua_State *L)
{
	int isnum;
	lua_Integer size, address;
	size = 1;

	switch (lua_gettop(L)) {
		case 2:
			size = lua_tointegerx(L, 2, &isnum);
			if (!isnum || size < 1 || size > 0xFFFF) {
				luaL_error(L, "bad argument to 'ptr'");
				return 0;
			}
		case 1:
			address = lua_tointegerx(L, 1, &isnum);
			if (!isnum || address < 0 || address > 0xFFFF) {
				luaL_error(L, "bad argument to 'ptr'");
				return 0;
			}
			break;
		case 0:
			luaL_error(L, "missing argument");
			return 0;
		default:
			luaL_error(L, "too many arguments");
			return 0;
	}

	lua_settop(L, 0); //Clear the stack
	lua_createtable(L, 0, 2);
	lua_pushinteger(L, address);
	lua_setfield(L, 1, "address");
	lua_pushinteger(L, size);
	lua_setfield(L, 1, "size");

	lua_createtable(L, 0, 3); //Pointer metatable
	lua_pushcfunction(L, luaF_ptr_index);
	lua_setfield(L, 2, "__index");
	lua_pushcfunction(L, luaF_ptr_newindex);
	lua_setfield(L, 2, "__newindex");
	lua_pushinteger(L, 0);
	lua_setfield(L, 2, "__metatable");
	
	lua_setmetatable(L, 1);
	return 1;
}

static struct breakpoint *createBreakpoint(lua_State *L, BREAK_TYPE type)
{
	//1: pointer, 2: [condition]
	struct memPointer pointer;

	//Check arguments
	lua_settop(L, 2);
	if(((lua_type(L, 2) != LUA_TNIL || type == TYPE_TRACE) &&
	    lua_type(L, 2) != LUA_TSTRING &&
	    lua_type(L, 2) != LUA_TFUNCTION)
	    || getMemPointer(L, 1, &pointer)) {
		luaL_error(L, "invalid arguments(s)");
	}

	//Allocate and set up a new breakpoint structure
	lua_getglobal(L, "breakpoints");
	lua_len(L, -1); //length of breakpoints table
	int index = 1 + lua_tointeger(L, -1);
	lua_pushinteger(L, index);
	struct breakpoint *bp = lua_newuserdata(L, sizeof(struct breakpoint));
	lua_rawgeti(L, LUA_REGISTRYINDEX, breakpointMetatable);
	lua_setmetatable(L, -2);
	lua_rawset(L, 3); //store the new breakpoint

	bp->index = index;
	bp->address = pointer.address;
	bp->size = pointer.size;
	bp->icount = 0;
	bp->ecount = 0;
	bp->type = type;
	lua_pushvalue(L, 2);
	bp->condition = luaL_ref(L, LUA_REGISTRYINDEX);

	return bp;
}

static int luaF_newBreakpoint(lua_State *L)
{
	struct breakpoint *bp = createBreakpoint(L, TYPE_BREAK);
	emu_registerBreakpoint(bp);
	return 0;
}

static int luaF_newTracepoint(lua_State *L)
{
	struct breakpoint *bp = createBreakpoint(L, TYPE_TRACE);
	emu_registerBreakpoint(bp);
	return 0;
}

static int luaF_newWatchpoint(lua_State *L)
{
	struct breakpoint *bp = createBreakpoint(L, TYPE_WATCH);
	emu_registerWatchpoint(bp);
	return 0;
}

static int luaF_addmodule(lua_State *L)
{
	int slot = 0;
	if (lua_isnoneornil(L, 2)) {
		//Find first free slot
		lua_getglobal(L, "modules");
		for (int i = 1; i <= 8; i++) {
			if (lua_geti(L, -1, i) == LUA_TNIL) {
				lua_pop(L, 1);
				slot = i;
				break;
			}
			lua_pop(L, 1);
		}
		lua_pop(L, 1);
		if (slot == 0) {
			return luaL_error(L, "no free slot");
		}
	} else {
		int isnum;
		slot = lua_tointegerx(L, 2, &isnum);
		if (!isnum || slot < 1 || slot > 8) {
			return luaL_error(L, "invalid argument");
		}
	}

	lua_getglobal(L, "modules");

	//Call require(modname)
	lua_getglobal(L, "require");
	lua_pushvalue(L, 1);
	lua_call(L, 1, 1);
	//Call the new() method
	lua_getfield(L, -1, "new");
	lua_call(L, 0, 1);

	lua_pushvalue(L, -1);
	lua_seti(L, -4, slot);
	return 1;
}
