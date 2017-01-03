#include <stdio.h>
//#include <iostream>
//#include <vector>
#include <ncurses.h>
//#include <errno.h>
//#include <string.h>
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



/*
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
*/


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



	//Start curses
	initscr();
	scrollok(stdscr, true);
	raw();
	noecho();
	nodelay(stdscr, true);

	//Start z80lib
	emulator_init();
	emulator_loadRom(romFile);

	while (1) {
		char c = getch();
		switch (c) {
			case 0x01:
				fclose(sd.imgFile);
				unlink("/tmp/zi28sim");
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
