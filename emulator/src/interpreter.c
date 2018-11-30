#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <readline/readline.h>
#include <readline/history.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

#include "interpreter.h"
#include "config.h"
#include "emulator.h"
#include "luainterface.h"
#include "command.h"

int quitRequest;

static lua_State *luaState;

static int incomplete (lua_State *L, int status);
static int pushline (lua_State *L, int firstline);
static int addreturn (lua_State *L);
static int multiline (lua_State *L);
static int docall (lua_State *L, int narg, int nres);
static void l_print (lua_State *L);
static int report (lua_State *L, int status);
static int msghandler (lua_State *L);

void interpreter_init()
{
	quitRequest = 0;

	lua_State *L = luaL_newstate();
	luaState = L;
	luaL_openlibs(L);

	setupLuaEnv(L);

	//Load configuration files
	char initFileName[] = "init.lua";
	char *configDir = getConfigDir();
	char *globalConfigFile = malloc(strlen(configDir) + strlen(initFileName) + 1);
	strcpy(globalConfigFile, configDir);
	strcat(globalConfigFile, initFileName);
	//TODO create stub if config file doesn't exist yet
	if (luaL_loadfile(L, globalConfigFile) || lua_pcall(L, 0, 0, 0)) {
		fprintf(stderr, "%s\n", lua_tostring(L, -1));
		lua_pop(L, 1);  /* pop error message from the stack */
	}

	free(globalConfigFile);
	free(configDir);

	using_history();
}

void interpreter_run()
{
	lua_State *L = luaState;
	int status;
	while (!quitRequest) {
		lua_settop(L, 0);
		if (!pushline(L, 1))
			break;  /* no input */
		if (asCommand(L)) {
			continue;
		} else if ((status = addreturn(L)) != LUA_OK) { /* 'return ...' did not work? */
			status = multiline(L);  /* try as command, maybe with continuation lines */
		}
		lua_remove(L, 1);  /* remove line from the stack */
		lua_assert(lua_gettop(L) == 1);

		if (status == LUA_OK) {
			status = docall(L, 0, LUA_MULTRET);
		}
		if (status == LUA_OK) l_print(L);
		else report(L, status);
	}
	lua_settop(L, 0);  /* clear stack */

	lua_close(L);
}

/* mark in error messages for incomplete statements */
#define EOFMARK		"<eof>"
#define marklen		(sizeof(EOFMARK)/sizeof(char) - 1)

/*
** Check whether 'status' signals a syntax error and the error
** message at the top of the stack ends with the above mark for
** incomplete statements.
*/
static int incomplete (lua_State *L, int status) {
	if (status == LUA_ERRSYNTAX) {
		size_t lmsg;
		const char *msg = lua_tolstring(L, -1, &lmsg);
		if (lmsg >= marklen && strcmp(msg + lmsg - marklen, EOFMARK) == 0) {
			lua_pop(L, 1);
			return 1;
		}
	}
	return 0;  /* else... */
}

/*
** Prompt the user, read a line, and push it into the Lua stack.
*/
static int pushline (lua_State *L, int firstline) {
	char *b;
	size_t l;
	const char *prmt = firstline ? "(zi28emu) " : "        > ";
	int readstatus = (((b)=readline(prmt)) != NULL);
	if (readstatus == 0)
		return 0;  /* no input (prompt will be popped by caller) */
	l = strlen(b);
	if (l > 0 && b[l-1] == '\n')  /* line ends with newline? */
		b[--l] = '\0';  /* remove it */
	if (firstline && b[0] == '=')  /* for compatibility with 5.2, ... */
		lua_pushfstring(L, "return %s", b + 1);  /* change '=' to 'return' */
	else
		lua_pushlstring(L, b, l);
	free(b);
	return 1;
}

/*
** Try to compile line on the stack as 'return <line>;'; on return, stack
** has either compiled chunk or original line (if compilation failed).
*/
static int addreturn (lua_State *L) {
	const char *line = lua_tostring(L, -1);  /* original line */
	const char *retline = lua_pushfstring(L, "return %s;", line);
	int status = luaL_loadbuffer(L, retline, strlen(retline), "=stdin");
	if (status == LUA_OK) {
		lua_remove(L, -2);  /* remove modified line */
		if (line[0] != '\0' && line[0] != ' ')  /* non empty? */
			add_history(line);  /* keep history */
	}
	else
		lua_pop(L, 2);  /* pop result from 'luaL_loadbuffer' and modified line */
	return status;
}

/*
** Read multiple lines until a complete Lua statement
*/
static int multiline (lua_State *L) {
	for (;;) {  /* repeat until gets a complete statement */
		size_t len;
		const char *line = lua_tolstring(L, 1, &len);  /* get what it has */
		int status = luaL_loadbuffer(L, line, len, "=stdin");  /* try it */
		if (!incomplete(L, status) || !pushline(L, 0)) {
			if (line[0] != ' ') add_history(line);  /* keep history */
			return status;  /* cannot or should not try to add continuation line */
		}
		lua_pushliteral(L, "\n");  /* add newline... */
		lua_insert(L, -2);  /* ...between the two lines */
		lua_concat(L, 3);  /* join them */
	}
}

/*
** Message handler used to run all chunks
*/
static int msghandler (lua_State *L) {
	const char *msg = lua_tostring(L, 1);
	if (msg == NULL) {  /* is error object not a string? */
		if (luaL_callmeta(L, 1, "__tostring") &&  /* does it have a metamethod */
		    lua_type(L, -1) == LUA_TSTRING)  /* that produces a string? */
			return 1;  /* that is the message */
		else
			msg = lua_pushfstring(L, "(error object is a %s value)",
			                         luaL_typename(L, 1));
	}
	luaL_traceback(L, L, msg, 1);  /* append a standard traceback */
	return 1;  /* return the traceback */
}

/*
** Interface to 'lua_pcall', which sets appropriate message function
** and C-signal handler. Used to run all chunks.
*/
static int docall (lua_State *L, int narg, int nres) {
	int status;
	int base = lua_gettop(L) - narg;  /* function index */
	lua_pushcfunction(L, msghandler);  /* push message handler */
	lua_insert(L, base);  /* put it under function and args */
	status = lua_pcall(L, narg, nres, base);
	lua_remove(L, base);  /* remove message handler from the stack */
	return status;
}

/*
** Prints (calling the Lua 'print' function) any values on the stack
*/
static void l_print (lua_State *L) {
	int n = lua_gettop(L);
	if (n > 0) {  /* any result to be printed? */
		luaL_checkstack(L, LUA_MINSTACK, "too many results to print");
		lua_getglobal(L, "print");
		lua_insert(L, 1);
		if (lua_pcall(L, n, 0, 0) != LUA_OK)
			fprintf(stderr, "%s\n", lua_pushfstring(L, "error calling 'print' (%s)",
			                                        lua_tostring(L, -1)));
	}
}

/*
** Check whether 'status' is not OK and, if so, prints the error
** message on the top of the stack. It assumes that the error object
** is a string, as it was either generated by Lua or by 'msghandler'.
*/
static int report (lua_State *L, int status) {
	if (status != LUA_OK) {
		const char *msg = lua_tostring(L, -1);
		fprintf(stderr, "%s\n", msg);
		lua_pop(L, 1);  /* remove message */
	}
	return status;
}
