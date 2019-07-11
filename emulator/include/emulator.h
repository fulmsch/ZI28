#ifndef EMULATOR_H
#define EMULATOR_H

#include <stdint.h>
#include <sys/time.h>
#include <lua.h>
#include <lauxlib.h>

#include "libz80/z80.h"

byte readMem(ushort address);
void writeMem(ushort address, byte data);

typedef enum {
	TYPE_BREAK, TYPE_TRACE, TYPE_WATCH
} BREAK_TYPE;

struct breakpoint{
	struct breakpoint *next;
	struct breakpoint *prev;
	int index;
	BREAK_TYPE type;
	uint16_t address;
	int size;
	int ecount;
	int icount;
	int condition;
};

struct {
	uint8_t rom[0x8000];
	uint8_t ram[0x20000];
	Z80Context context;
	uint64_t clockCycles;
	union {
		uint8_t bankReg;
		struct {
			uint8_t ramBank: 3;
			uint8_t romBank: 1;
		};
	};
	struct timeval startTime;
	struct breakpoint *breakpoints[0x10000];
	struct breakpoint *watchpoints[0x10000];
} zi28;

extern int breakpoints[0x10000];

typedef enum {
	EMU_OK, EMU_BREAK, EMU_INTERRUPT, EMU_ERR
} EMU_STATUS;

typedef enum {
	EMU_RUN, EMU_CONTINUE, EMU_STEP, EMU_NEXT, EMU_FINISH, EMU_ADVANCE, EMU_OUT
} EMU_MODE;

void emu_init(void);
EMU_STATUS emu_run(lua_State *L, EMU_MODE mode, int arg);

int emu_loadRom(char *romFile);
void emu_reset(void);

void emu_break(void);

void emu_registerBreakpoint(struct breakpoint *bp);
void emu_registerWatchpoint(struct breakpoint *bp);

#endif
