//#include <stdio.h>
//#include <iostream>
//#include <vector>
#include <ncurses.h>
#include <poll.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>

extern "C" {
	#include <z80.h>
}

#include "main.h"
#include "module.h"
#include "sd.h"

extern int errno;


FILE *memFile;
byte memory[0x10000];
static Z80Context context;
SdCard sd("/home/florian/sd.img");

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

struct pollfd pty[1];

int main(int argc, char **argv) {
	int hflag = 0;
	int tflag = 0;
	int rflag = 0;
	char *terminalFile;
	char *romFile;
	int c;
	while ((c = getopt(argc, argv, "ht:r:")) != -1) {
		switch (c) {
			case 'h':
				hflag = 1;
				break;
			case 't':
				tflag = 1;
				terminalFile = optarg;
				break;
			case 'r':
				rflag = 1;
				romFile = optarg;
				break;
			case '?':
				fprintf(stderr, "Invalid invocation\nUse '-h' for help\n");
				return 1;
			default:
				return 1;
		}
	}

	if (hflag) {
		printf("Usage: zi28sim [options] -t terminal -r rom image\n");
		return 0;
	}

	if (!tflag || !rflag) {
		fprintf(stderr, "Missing argument(s)\nUse '-h' for help\n");
		return 1;
	}

	memFile = fopen(romFile, "rb");
	fread(memory, 1, 0x10000, memFile);
	fclose(memFile);

	int ptyfd = open(terminalFile, O_RDWR | O_NOCTTY | O_NDELAY | O_NONBLOCK);
	if (ptyfd < 0){
		printf("error");
		fprintf(stderr, "Value of errno: %d\n", errno);
		fprintf(stderr, "Error opening file: %s\n", strerror(errno));
		return 2;}
	pty[0].fd = ptyfd;
	pty[0].events = POLLIN;



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
		switch (c) {
			case 0x01:
				endwin();
				return 0;
			case 0x12:
				Z80RESET(&context);
				break;
			default:
				break;
		}
		Z80Execute(&context);

	}
	return 1;
}

static byte context_mem_read_callback(int param, ushort address) {
	return memory[address];
}

static void context_mem_write_callback(int param, ushort address, byte data) {
	memory[address] = data;
}

static byte context_io_read_callback(int param, ushort address) {
	int data=0xff;
	int ret;
	address = address & 0xff;

	if (address >= 0x80) {
		int base = (address - 0x80) / 0x10;
		ushort offs = (address - 0x80) % 0x10;
		data = modules[base] -> read(offs);

	} else {
		switch (address) {
			case 0x00:
				read(pty[0].fd, &data, 1);
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
		int base = (address - 0x80) / 0x10;
		ushort offs = (address - 0x80) % 0x10;
		modules[base] -> write(offs, data);

	} else {
		switch (address) {
			case 0x00:
				if (data != 0x0D) write(pty[0].fd, &data, 1);
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
