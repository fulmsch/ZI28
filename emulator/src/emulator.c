#include <termios.h>
#include <pty.h>
#include <stdlib.h>
#include <poll.h>
#include <unistd.h>
#include <fcntl.h>
#include <time.h>
#include <signal.h>
#include <string.h>

#include "main.h"
#include "emulator.h"
#include "libz80/z80.h"
#include "luainterface.h"
#include "interpreter.h"
#include "ui.h"

sig_atomic_t interruptFlag = 0;

static EMU_STATUS doStep(lua_State *L);

static byte context_mem_read_callback(int param, ushort address);
static void context_mem_write_callback(int param, ushort address, byte data);
static byte context_io_read_callback(int param, ushort address);
static void context_io_write_callback(int param, ushort address, byte data);

static int breakflag; //TODO also store the watchpoint that was triggered

FILE *memFile;

int breakpoints[0x10000];
struct pollfd pty[1];
struct termios ptyTermios;

byte readMem(ushort address)
{
	if (address < 0x4000) {
		//rom
		return zi28.rom[address + zi28.romBank * 0x4000];
	} else if (address >= 0xc000) {
		//banked ram
		return zi28.ram[address + 0x4000 + zi28.ramBank * 0x2000];
	} else {
		//regular ram
		return zi28.ram[address - 0x4000];
	}
}

void writeMem(ushort address, byte data)
{
	if (address < 0x4000) {
		//rom
		printf("rom write 0x%04x\n", zi28.context.PC);
		//emu_break();
		if (!romProtect) {
			zi28.rom[address + zi28.romBank * 0x4000] = data;
		}
	} else if (address >= 0xc000) {
		//banked ram
		zi28.ram[address + 0x4000 + zi28.ramBank * 0x2000] = data;
	} else {
		//regular ram
		zi28.ram[address - 0x4000] = data;
	}
}

static int evaluateCondition(lua_State *L, struct breakpoint *bp)
{
	//Return -1 on error, 0 if false, 1 if true
	//If string and breakpoint: add return
	int status;
	lua_rawgeti(L, LUA_REGISTRYINDEX, bp->condition);
	if (lua_isstring(L, -1)) {
		const char *fmt = (bp->type == TYPE_BREAK) ? "return %s;" : "%s;";
		const char *line = lua_tostring(L, -1);  /* original line */
		const char *retline = lua_pushfstring(L, fmt, line);
		status = luaL_loadbuffer(L, retline, strlen(retline), "=condition");
		if (status == LUA_OK) {
			lua_remove(L, -2);  /* remove modified line */
		} else {
			lua_pop(L, 2);  /* pop result from 'luaL_loadbuffer' and modified line */
			return -1;
		}
	} else if (!lua_isfunction(L, -1)) {
		lua_pop(L, 1);
		return -1;
	}

	lua_pushinteger(L, bp->index);

	lua_call(L, 1, 1);
	return lua_toboolean(L, -1);

	/* This might be better, but needs a message handler for pcall
	status = lua_pcall(L, 1, 1, 0);
	if (status == LUA_OK) {
		return lua_toboolean(L, -1);
	} else {
		lua_pop(L, 1);
		return -1;
	}
	*/
}

static EMU_STATUS handleBreakpoint(lua_State *L, struct breakpoint *bp)
{
// icount: ignore until 0, -1: disabled
// ecount: disable when 0, -1: delete next time

	EMU_STATUS status = EMU_OK;

	if (bp->icount == -1) goto next; //disabled
	if (bp->icount > 0) {
		//Decrement ignore count and continue
		bp->icount -= 1;
		goto next;
	}
	if (bp->condition != LUA_REFNIL) {
		//check condition
		int ret = evaluateCondition(L, bp);
		if (ret == -1) return EMU_ERR;
		else if (ret == 0 && bp->type == TYPE_BREAK) goto next;
	}
	if (bp->ecount == -1) {
		//TODO delete breakpoint
	} else if (bp->ecount > 0) {
		if ((--bp->ecount) == 0) bp->icount = -1;
	}
	if (bp->type == TYPE_BREAK) {
		status = EMU_BREAK;
	}

next:
	if (bp->next != NULL) {
		EMU_STATUS ret = handleBreakpoint(L, bp->next);
		return (ret != EMU_OK) ? ret : status;
	} else {
		return status;
	}
}

static void registerBreakpoint(struct breakpoint *bp, struct breakpoint **table, int address)
{
	bp->prev = NULL;
	bp->next = NULL;

	if (table[address] == NULL) {
		table[address] = bp;
	} else {
		struct breakpoint *last = table[address];
		while (last->next != NULL) last = last->next;
		last->next = bp;
		bp->prev = last;
	}
}

void emu_registerBreakpoint(struct breakpoint *bp)
{
	registerBreakpoint(bp, zi28.breakpoints, bp->address);
}

void emu_registerWatchpoint(struct breakpoint *bp)
{
	for (int i = 0; i < bp->size; i++) {
		registerBreakpoint(bp, zi28.watchpoints, bp->address + i);
	}
}

void emu_init() {
	int ptm, pts;
	char *ptsName;
	ptsName = (char*) malloc(50);
	openpty(&ptm, &pts, ptsName, NULL, NULL);
	tcgetattr(ptm, &ptyTermios);
	cfmakeraw(&ptyTermios);
	tcsetattr(ptm, TCSANOW, &ptyTermios);


	symlink(ptsName, "/tmp/zi28tty");
	free(ptsName);

	pty[0].fd = STDIN_FILENO;
	pty[0].events = POLLIN;

	romProtect = 1;

	breakflag = 0;

	zi28.context.memRead = context_mem_read_callback;
	zi28.context.memWrite = context_mem_write_callback;
	zi28.context.ioRead = context_io_read_callback;
	zi28.context.ioWrite = context_io_write_callback;
	emu_reset();
	zi28.clockCycles = 0;
	for (int i = 0; i < 0x10000; i++) {
		zi28.breakpoints[i] = NULL;
		zi28.watchpoints[i] = NULL;
	}
}

void emu_break()
{
	interruptFlag = 1;
	return;
}

extern sig_atomic_t interruptFlag;

int emu_loadRom(char *romFileName) {
	if(!(memFile = fopen(romFileName, "rb"))) return -1;
	fread(zi28.rom, 1, 0x8000, memFile);
	fclose(memFile);
	return 0;
}

void emu_reset() {
	Z80RESET(&zi28.context);

	zi28.bankReg = 0;
}

static EMU_STATUS mode_run(lua_State *L, int arg)
{
	EMU_STATUS ret;
	do {
		ret = doStep(L);
	} while (ret == EMU_OK);
	return ret;
}

static EMU_STATUS mode_continue(lua_State *L, int arg)
{
	EMU_STATUS ret;
	do {
		ret = doStep(L);
	} while (ret == EMU_OK);
	return ret;
}

static EMU_STATUS mode_step(lua_State *L, int arg)
{
	EMU_STATUS ret;
	if (arg < 1) arg = 1;
	do {
		ret = doStep(L);
	} while (--arg > 0 && ret == EMU_OK);

	return ret;
}

static EMU_STATUS mode_finish(lua_State *L, int arg)
{
	//seems to work, TODO more extensive testing
	EMU_STATUS ret;
	unsigned short prevSP;
	int possibleReturn;
	do {
		prevSP = zi28.context.R1.wr.SP;
		switch(zi28.ram[zi28.context.PC]) {
			case 0xC0: case 0xD0: case 0xE0: case 0xF0:
			case 0xC8: case 0xD8: case 0xE8: case 0xF8:
			case 0xC9:
				possibleReturn = 1;
				break;
			case 0xED:
				switch(zi28.ram[zi28.context.PC + 1]) {
					case 0x45: case 0x55: case 0x65: case 0x75:
					case 0x4D: case 0x5D: case 0x6D: case 0x7D:
						possibleReturn = 1;
						break;
					default:
						possibleReturn = 0;
						break;
				}
			default:
				possibleReturn = 0;
				break;
		}
		ret = doStep(L);
	} while (ret == EMU_OK && !possibleReturn && zi28.context.R1.wr.SP == prevSP);

	return ret;
}

static EMU_STATUS mode_next(lua_State *L, int arg)
{
	//TODO testing
	EMU_STATUS ret;
	unsigned short prevSP;
	int possibleCall;
	if (arg < 1) arg = 1;
	do {
		prevSP = zi28.context.R1.wr.SP;
		switch(zi28.ram[zi28.context.PC]) {
			case 0xC4: case 0xD4: case 0xE4: case 0xF4:
			case 0xCC: case 0xDC: case 0xEC: case 0xFC:
			case 0xCD:
				possibleCall = 1;
				break;
			default:
				possibleCall = 0;
				break;
		}
		ret = doStep(L);
		if (!possibleCall && zi28.context.R1.wr.SP == prevSP) {
			ret = mode_finish(L, 0);
		}
	} while (--arg > 0 && ret == EMU_OK);

	return ret;
}

static EMU_STATUS mode_advance(lua_State *L, int arg)
{
	EMU_STATUS ret = EMU_OK;
	if (arg < 0 || arg > 0xffff) {
		return EMU_ERR;
	}
	while (ret == EMU_OK && zi28.context.PC != arg) {
		ret = doStep(L);
	}
	return ret;
}

static EMU_STATUS mode_out(lua_State *L, int arg)
{
	EMU_STATUS ret = EMU_OK;
	int address;
	if (arg > 0 && arg < 0xffff) {
		address = arg;
	} else {
		char dump[20];
		Z80Debug(&zi28.context, dump, NULL);
		address = zi28.context.PC + (strlen(dump) / 2);
	}
	while (ret == EMU_OK && zi28.context.PC != address) {
		ret = doStep(L);
	}
	return ret;
}

static EMU_STATUS (*mode_functions[])(lua_State *, int) = {
	mode_run, mode_continue, mode_step, mode_next, mode_finish, mode_advance, mode_out
};

EMU_STATUS emu_run(lua_State *L, EMU_MODE mode, int arg)
{
	if (mode < 0 || mode >= sizeof(mode_functions)/sizeof(EMU_STATUS (*)(int))) {
		return EMU_ERR;
	}

	struct termios orig_termios;
	tcgetattr(STDIN_FILENO, &orig_termios);
	struct termios raw = orig_termios;
	//raw.c_iflag &= ~(BRKINT | ICRNL | INPCK | ISTRIP | IXON);
	//raw.c_oflag &= ~(OPOST);
	//raw.c_cflag |= (CS8);
	//raw.c_lflag &= ~(ECHO | ICANON | IEXTEN | ISIG);
	raw.c_lflag &= ~(ECHO | ICANON);
	tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw);

	gettimeofday(&zi28.startTime, NULL);
	zi28.context.tstates = 0;
	EMU_STATUS ret = mode_functions[mode](L, arg);
	zi28.clockCycles += zi28.context.tstates;

	tcsetattr(STDIN_FILENO, TCSAFLUSH, &orig_termios);

	printInstruction(&zi28.context);

	return ret;
}

static EMU_STATUS doStep(lua_State *L)
{
	if (interruptFlag) {
		interruptFlag = 0;
		printf("\n");
		return EMU_INTERRUPT;
	}
	Z80Execute(&zi28.context);
	if (zi28.breakpoints[zi28.context.PC] != NULL) {
		switch (handleBreakpoint(L, zi28.breakpoints[zi28.context.PC])) {
			case EMU_BREAK:
				printInstruction(&zi28.context);
				return EMU_BREAK;
			case EMU_OK:
				break;
			case EMU_ERR:
			default:
				return EMU_ERR;
		}
	}
	if (breakflag) {
		breakflag = 0;
		return EMU_BREAK;
	}
	if (zi28.context.tstates >= 80000) {
		struct timeval tv2;
		gettimeofday(&tv2, NULL);
		long int dtime = tv2.tv_usec - zi28.startTime.tv_usec; //TODO also use seconds
		if (dtime > 0) {
			unsigned long targetTime = 10000; //0.01s = 10ms = 10'000us
			struct timespec sleeptime, remtime;
			sleeptime.tv_sec = 0;
			sleeptime.tv_nsec = (targetTime - dtime) * 1000L;
			nanosleep(&sleeptime, &remtime);
		}
		zi28.clockCycles += zi28.context.tstates;
		zi28.context.tstates = 0;
		gettimeofday(&zi28.startTime, NULL);
	}
	return EMU_OK;
}

static byte context_mem_read_callback(int param, ushort address) {
	return readMem(address);
}

static void context_mem_write_callback(int param, ushort address, byte data) {
	if (zi28.watchpoints[address]) breakflag = 1;
	writeMem(address, data);
}

static byte context_io_read_callback(int param, ushort address) {
	static char lastTtyChar;
	char data=0xff;
	int ret;
	address = address & 0xff;

	if (address >= 0x80) {
		int module = (address - 0x80) / 0x10;
		int offs = (address - 0x80) % 0x10;
		lua_State *L = globalLuaState;
		int top = lua_gettop(L);
		lua_getglobal(L, "modules");
		if (lua_geti(L, -1, module + 1) == LUA_TNIL) return data;
		lua_getfield(L, -1, "read");
		if (lua_isfunction(L, -1)) {
			lua_insert(L, -2);
			lua_pushinteger(L, offs);
			lua_call(L, 2, 1);
			data = lua_tointeger(L, -1);
		}
		lua_settop(L, top);
	} else {
		switch (address) {
			case 0x00:
				ret = poll(pty, 1, 0);
				if ((ret > 0) && (pty[0].revents & POLLIN)) {
					//new char available
					read(pty[0].fd, &data, 1);
					if (data == 127) data = 8;
					lastTtyChar = data;
				} else {
					data = lastTtyChar;
				}
				break;
			case 0x01:
				data = 0x02;
				ret = poll(pty, 1, 0);
				if ((ret > 0) && (pty[0].revents & POLLIN)) {
					data = 0x00;
				}
				break;
			default:
				break;
		}
	}

	return data;
}

static void context_io_write_callback(int param, ushort address, byte data) {
	address = address & 0xff; // port address
	if (address >= 0x80) {
		int module = (address - 0x80) / 0x10;
		int offs = (address - 0x80) % 0x10;
		lua_State *L = globalLuaState;
		int top = lua_gettop(L);
		lua_getglobal(L, "modules");
		if (lua_geti(L, -1, module + 1) == LUA_TNIL) return;
		lua_getfield(L, -1, "write");
		if (lua_isfunction(L, -1)) {
			lua_insert(L, -2);
			lua_pushinteger(L, offs);
			lua_pushinteger(L, data);
			lua_call(L, 3, 0);
		}
		lua_settop(L, top);
	} else {
		switch (address) {
			case 0x00:
				write(pty[0].fd, &data, 1);
				break;
			case 0x02:
				zi28.bankReg = data;
				break;
			default:
				break;
		}
	}
}
