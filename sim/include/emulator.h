#ifndef EMULATOR_H
#define EMULATOR_H

FILE *memFile;
byte memory[0x10000];
Z80Context context;
struct SdCard sd;
struct SdModule sdModule;
struct pollfd pty[1];
struct termios ptyTermios;

void emulator_init(void);
void emulator_loadRom(char *romFile);
void emulator_reset(void);
void emulator_runCycles(int n);

byte context_mem_read_callback(int param, ushort address);
void context_mem_write_callback(int param, ushort address, byte data);
byte context_io_read_callback(int param, ushort address);
void context_io_write_callback(int param, ushort address, byte data);

#endif
