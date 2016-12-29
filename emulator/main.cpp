//#include <stdio.h>
#include <iostream>
#include <vector>
#include <ncurses.h>

extern "C" {
	#include <z80.h>
}

#include "main.h"
#include "module.h"
#include "sd.h"


FILE *memFile;
FILE *sdFile;
//static byte memory[0x10000] = {0xDB, 0x01, 0xCB, 0x4F, 0x20, 0xFA, 0xDB, 0x00, 0xD3, 0x00, 0x18, 0xF4};
byte memory[0x10000];
static Z80Context context;
SdCard sd(sdFile);

Module* modules[8] = {
	new SdModule(sd),
	new Module,
	new Module,
	new Module,
	new Module,
	new Module,
	new Module,
	new Module
};

char inputChar;
int inputAvailable;
int crFlag;

static byte context_mem_read_callback(int param, ushort address) {
	return memory[address];
}

static void context_mem_write_callback(int param, ushort address, byte data) {
	memory[address] = data;
}

static byte context_io_read_callback(int param, ushort address) {
	int data=0xff;
	address = address & 0xff;

	if (address >= 0x80) {
		int base = (address - 0x80) / 0x10;
		ushort offs = (address - 0x80) % 0x10;
		data = modules[base] -> read(offs);

	} else {
		switch (address) {
			case 0x00:
				data = inputChar;
				inputAvailable = 0;
				break;
			case 0x01:
				data = 0x02;
				if (inputAvailable) {
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
		int base = (address - 0x80) / 0x10;
		ushort offs = (address - 0x80) % 0x10;
		modules[base] -> write(offs, data);

	} else {
		switch (address) {
			case 0x00:
				if (data != 0x0D) addch(data);
				break;
			default:
				break;
		}
	}
}

void init_emulator() {
	context.memRead = context_mem_read_callback;
	context.memWrite = context_mem_write_callback;
	context.ioRead = context_io_read_callback;
	context.ioWrite = context_io_write_callback;
}

int main(int argc, char **argv) {
	if (argc != 2) {
		std::cout<<"Error: no memory image specified";
		return -1;
	}
	memFile = fopen(argv[1], "rb");
	fread(memory, 1, 0x10000, memFile);
	fclose(memFile);
	sdFile = fopen("/home/florian/sd2.img", "rb");

	//Start curses
	initscr();
	scrollok(stdscr, true);
	raw();
	noecho();
	nodelay(stdscr, true);

	//Start z80lib
	init_emulator();

	while (1) {
		char c = getch();
		if (c == 1) {
			endwin();
			return 0;
		}
		else if (c != ERR) {
			//read input
			if (!inputAvailable) {
				if (c == 0x0a) {
					if (!crFlag) {
						ungetch(c);
						c = 0x0d;
						crFlag = 1;
					}else {
						crFlag = 0;
					}
				}
				inputChar = c;
				inputAvailable = 1;
			}
			else {
				ungetch(c);
			}
		}

		Z80Execute(&context);

	}
	return 1;
}
