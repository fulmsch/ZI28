#ifndef EMULATOR_H
#define EMULATOR_H

FILE *memFile;

struct {
	unsigned char rom[0x8000];
	unsigned char ram[0x20000];
	Z80Context context;
	union {
		unsigned char bankReg;
		struct {
			unsigned char ramBank: 3;
			unsigned char romBank: 1;
		};
	};
} zi28;

int breakpoints[0x10000];
struct SdCard sd;
struct SdModule sdModule;
struct pollfd pty[1];
struct termios ptyTermios;

void emulator_init(void);
int emulator_loadRom(char *romFile);
void emulator_reset(void);
int emulator_runCycles(int n_cycles, int useBreakpoints);

byte context_mem_read_callback(int param, ushort address);
void context_mem_write_callback(int param, ushort address, byte data);
byte context_io_read_callback(int param, ushort address);
void context_io_write_callback(int param, ushort address, byte data);

#endif
