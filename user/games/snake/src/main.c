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

static char key, status;

void handleKey(char key)
{
	switch (key) {
		case 0x03:
		case 'q':
		case EOF:
			quit(0);
		case 'h':
		case 'a':
			snake_setDir(LEFT);
			break;
		case 'j':
		case 's':
			snake_setDir(DOWN);
			break;
		case 'k':
		case 'w':
			snake_setDir(UP);
			break;
		case 'l':
		case 'd':
			snake_setDir(RIGHT);
			break;
		case 'r':
			break;
		case 'n':
			break;
		case 'p':
			while (getchar() != 'p');
		default:
			break;
	}
}

void keyPoll(void)
{
#define DATA_PORT 0x00
#define STATUS_PORT 0x01
	int count = 150 - 5 * (score <= 20 ? score : 20);

	while (count --> 0) {
		t_delay(80000); //~10ms

	#asm
		in a, (STATUS_PORT)
		ld (_status), a
	#endasm

		if (!(status & 0x02)) {
		#asm
			in a, (DATA_PORT)
			ld(_key), a
		#endasm
			handleKey(key);
		}
	}
}

void quit(int ret)
{
	vt100_set_cursor(grid_height + 4, 1);
	vt100_show_cursor();
	exit(ret);
}

int main(int argc, char **argv) {
//	if (vt100_get_status()) return 1;
	//TODO check screen size

#ifdef __Z88DK
	randomize();
#else
	srand(time(NULL));
#endif

	vt100_clear_screen();
	vt100_hide_cursor();
	vt100_set_cursor(0, 0);

	initGame();

	while (!gameOver) {
		keyPoll();
		snake_move();
	}
	quit(0);
}
