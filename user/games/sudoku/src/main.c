#include <assert.h>

#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>
#include <stdlib.h>
#ifndef __Z88DK
#include <time.h>
#endif
#include "main.h"
#include "game.h"
#include "ui.h"
#include "vt100.h"

static int c;
int gameOver;
int boardGenerated;

int main(int argc, char **argv) {
	if (vt100_get_status()) return 1;
	//TODO check screen size

#ifdef __Z88DK
	randomize();
#else
	srand(time(NULL));
#endif

	vt100_clear_screen();
	vt100_hide_cursor();
	vt100_set_cursor(0, 0);

	loadPuzzle();
	drawInitialBoard();
	updateCursor();

	while (1) {
		c = getchar();

		switch (c) {
			case 0x03:
			case 'q':
			case EOF:
				vt100_set_cursor(15, 1);
				vt100_show_cursor();
				return 0;
			case 'h':
				moveCursor(LEFT);
				break;
			case 'j':
				moveCursor(DOWN);
				break;
			case 'k':
				moveCursor(UP);
				break;
			case 'l':
				moveCursor(RIGHT);
				break;
			default:
				if (c >= '0' && c <= '9') {
					setField(c - '0');
				}
		}
	}
	vt100_set_cursor(15, 1);
	vt100_show_cursor();
	return 0;
}
