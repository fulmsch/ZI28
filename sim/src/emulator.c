#include <termios.h>
#include <pty.h>
#include <stdlib.h>
#include <poll.h>
#include <unistd.h>
#include <fcntl.h>
#include <z80.h>

#include "main.h"
#include "emulator.h"
#include "sd.h"

char lastTtyChar = 0;

void emulator_init() {
	int ptm, pts;
	char *ptsName;
	ptsName = (char*) malloc(50);
	openpty(&ptm, &pts, ptsName, NULL, NULL);
	tcgetattr(ptm, &ptyTermios);
	cfmakeraw(&ptyTermios);
	tcsetattr(ptm, TCSANOW, &ptyTermios);


	symlink(ptsName, "/tmp/zi28sim");
	free(ptsName);

	pty[0].fd = ptm;
	pty[0].events = POLLIN;

	romProtect = 1;

	if (!(sd.imgFile = fopen("/home/florian/sd.img", "r+"))) {
		fprintf(stderr, "Error: can't open SD image file.\n");
		exit(1);
	}
	sd.status = IDLE;
	sdModule.card = &sd;

	context.memRead = context_mem_read_callback;
	context.memWrite = context_mem_write_callback;
	context.ioRead = context_io_read_callback;
	context.ioWrite = context_io_write_callback;
}

int emulator_loadRom(char *romFile) {
	if(!(memFile = fopen(romFile, "rb"))) return -1;
	fread(memory, 1, 0x10000, memFile);
	fclose(memFile);
	return 0;
}

void emulator_reset() {
	Z80RESET(&context);
}

int emulator_runCycles(int n_cycles, int useBreakpoints) {
	context.tstates = 0;
	if (useBreakpoints) {
		while (context.tstates < n_cycles) {
			Z80Execute(&context);
			if (breakpoints[context.PC]) {
				return 1;
			}
		}
	} else {
		while (context.tstates < n_cycles) {
			Z80Execute(&context);
		}
	}
	return 0;
}


byte context_mem_read_callback(int param, ushort address) {
	return memory[address];
}

void context_mem_write_callback(int param, ushort address, byte data) {
	if (address > 0x1FFF || !romProtect) {
		memory[address] = data;
	}
}

byte context_io_read_callback(int param, ushort address) {
	char data=0xff;
	int ret;
	address = address & 0xff;

	if (address >= 0x80) {
		int base = (address - 0x80) / 0x10;
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

void context_io_write_callback(int param, ushort address, byte data) {
	address = address & 0xff; // port address
	if (address >= 0x80) {
		int base = (address - 0x80) / 0x10;
		ushort offs = (address - 0x80) % 0x10;
		SdModule_write(&sdModule, offs, data);

	} else {
		switch (address) {
			case 0x00:
				write(pty[0].fd, &data, 1);
				break;
			default:
				break;
		}
	}
}
