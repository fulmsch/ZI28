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


	symlink(ptsName, "/tmp/zi28tty");
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

	zi28.context.memRead = context_mem_read_callback;
	zi28.context.memWrite = context_mem_write_callback;
	zi28.context.ioRead = context_io_read_callback;
	zi28.context.ioWrite = context_io_write_callback;
	emulator_reset();
}

int emulator_loadRom(char *romFile) {
	if(!(memFile = fopen(romFile, "rb"))) return -1;
	fread(zi28.rom, 1, 0x8000, memFile);
	fclose(memFile);
	return 0;
}

void emulator_reset() {
	Z80RESET(&zi28.context);

	zi28.bankReg = 0;
}

int emulator_runCycles(int n_cycles, int useBreakpoints) {
	zi28.context.tstates = 0;
	if (useBreakpoints) {
		while (zi28.context.tstates < n_cycles) {
			Z80Execute(&zi28.context);
			if (breakpoints[zi28.context.PC]) {
				return 1;
			}
		}
	} else {
		while (zi28.context.tstates < n_cycles) {
			Z80Execute(&zi28.context);
		}
	}
	return 0;
}


byte context_mem_read_callback(int param, ushort address) {
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

void context_mem_write_callback(int param, ushort address, byte data) {
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
			case 0x02:
				zi28.bankReg = data;
				break;
			default:
				break;
		}
	}
}
