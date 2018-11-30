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
#include "sd.h"
#include "libz80/z80.h"
#include "luainterface.h"

sig_atomic_t interruptFlag = 0;

static EMU_STATUS doStep(lua_State *L);

static byte context_mem_read_callback(int param, ushort address);
static void context_mem_write_callback(int param, ushort address, byte data);
static byte context_io_read_callback(int param, ushort address);
static void context_io_write_callback(int param, ushort address, byte data);

static int running;

char lastTtyChar = 0;

FILE *memFile;

int breakpoints[0x10000];
struct SdCard sd;
struct SdModule sdModule;
struct pollfd pty[1];
struct termios ptyTermios;

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

	if (bp->icount == -1) goto nobreak; //disabled
	if (bp->icount > 0) {
		//Decrement ignore count and continue
		bp->icount -= 1;
		goto nobreak;
	}
	if (bp->condition != LUA_REFNIL) {
		//check condition
		int ret = evaluateCondition(L, bp);
		if (ret == -1) return EMU_ERR;
		else if (ret == 0 && bp->type == TYPE_BREAK) goto nobreak;
	}
	if (bp->ecount == -1) {
		//TODO delete breakpoint
	} else if (bp->ecount > 0) {
		if ((--bp->ecount) == 0) bp->icount = -1;
	}
	if (bp->type == TYPE_BREAK) return EMU_BREAK;

nobreak:
	if (bp->next != NULL) {
		return handleBreakpoint(L, bp->next);
	} else {
		return EMU_OK;
	}
}

static void registerBreakpoint(struct breakpoint *bp, struct breakpoint **table)
{
	bp->prev = NULL;
	bp->next = NULL;

	if (table[bp->address] == NULL) {
		table[bp->address] = bp;
	} else {
		struct breakpoint *last = table[bp->address];
		while (last->next != NULL) last = last->next;
		last->next = bp;
		bp->prev = last;
	}
}

void emu_registerBreakpoint(struct breakpoint *bp)
{
	registerBreakpoint(bp, zi28.breakpoints);
}

void emu_registerWatchpoint(struct breakpoint *bp)
{
	registerBreakpoint(bp, zi28.watchpoints);
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

	pty[0].fd = ptm;
	pty[0].events = POLLIN;

	romProtect = 1;

	if (sdFileName != NULL) {
		if (!(sd.imgFile = fopen(sdFileName, "r+"))) {
			fprintf(stderr, "Error: can't open SD image file.\n");
			exit(1);
		}
		sd.status = IDLE;
		sdModule.card = &sd;
	} else {
		sdModule.card = NULL;
	}

	zi28.context.memRead = context_mem_read_callback;
	zi28.context.memWrite = context_mem_write_callback;
	zi28.context.ioRead = context_io_read_callback;
	zi28.context.ioWrite = context_io_write_callback;
	emu_reset();
	running = 0;
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

static EMU_STATUS (*mode_functions[])(lua_State *, int) = {
	mode_run, mode_continue
};

EMU_STATUS emu_run(lua_State *L, EMU_MODE mode, int arg)
{
	if (mode < 0 || mode >= sizeof(mode_functions)/sizeof(EMU_STATUS (*)(int))-1) {
		return EMU_ERR;
	}

	gettimeofday(&zi28.startTime, NULL);
	zi28.context.tstates = 0;
	EMU_STATUS ret = mode_functions[mode](L, arg);
	zi28.clockCycles += zi28.context.tstates;

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
		EMU_STATUS ret = handleBreakpoint(L, zi28.breakpoints[zi28.context.PC]);
		if (ret != EMU_OK) return ret;
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

static void context_mem_write_callback(int param, ushort address, byte data) {
	if (address < 0x4000) {
		//rom
		if (!romProtect) {
			zi28.rom[address + zi28.romBank * 0x2000] = data;
		}
	} else if (address >= 0xc000) {
		//banked ram
		zi28.ram[address + 0x4000 + zi28.ramBank * 0x2000] = data;
	} else {
		//regular ram
		zi28.ram[address - 0x4000] = data;
	}
}

static byte context_io_read_callback(int param, ushort address) {
	char data=0xff;
	int ret;
	address = address & 0xff;

	if (address >= 0x80) {
//		int base = (address - 0x80) / 0x10;
		ushort offs = (address - 0x80) % 0x10;
		data = SdModule_read(&sdModule, offs);

	} else {
		switch (address) {
			case 0x00:
				ret = poll(pty, 1, 0);
				if ((ret > 0) && (pty[0].revents & POLLIN)) {
					//new char available
					read(pty[0].fd, &data, 1);
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
//		int base = (address - 0x80) / 0x10;
		ushort offs = (address - 0x80) % 0x10;
		SdModule_write(&sdModule, offs, data);

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
