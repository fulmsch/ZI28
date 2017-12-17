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

void setDifficulty() {
	char c;
	printf("Select difficulty:\n"\
	       "\t1: Beginner     9 x  9, 10 Mines\n"\
	       "\t2: Intermiate  16 x 16, 40 Mines\n"\
	       "\t3: Expert      30 x 16, 99 Mines\n");
	while (1) {
		switch (c = getchar()) {
			case 'q':
			case 0x03:
				exit(0);
			case '1':
				boardWidth = BEGINNER_WIDTH;
				boardHeight = BEGINNER_HEIGHT;
				totalMines = BEGINNER_MINES;
				break;
			case '2':
				boardWidth = INTERMEDIATE_WIDTH;
				boardHeight = INTERMEDIATE_HEIGHT;
				totalMines = INTERMEDIATE_MINES;
				break;
			case '3':
				boardWidth = EXPERT_WIDTH;
				boardHeight = EXPERT_HEIGHT;
				totalMines = EXPERT_MINES;
				break;
			default:
				continue;
		}
		return;
	}
}


int main(int argc, char **argv) {
	if (vt100_get_status()) return 1;
	//TODO check screen size

#ifdef __Z88DK
	randomize();
#else
	srand(time(NULL));
#endif

	setDifficulty();

	vt100_clear_screen();
	vt100_hide_cursor();
	vt100_set_cursor(0, 0);

	hiddenFields = boardWidth * boardHeight;
	unflaggedMines = totalMines;

	drawInitialBoard(boardWidth, boardHeight);
	updateCursor();

	while (!gameOver && hiddenFields > totalMines) {
		c = getchar();

		switch (c) {
			case 0x03:
			case 'q':
			case EOF:
				vt100_set_cursor(boardHeight + 4, 1);
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
			case 'f':
				if (boardStatus[cursor] == HIDDEN) {
					boardStatus[cursor] = FLAGGED;
					unflaggedMines--;
					drawField(cursor);
					printStatus();
				} else if (boardStatus[cursor] == FLAGGED) {
					boardStatus[cursor] = HIDDEN;
					unflaggedMines++;
					drawField(cursor);
					printStatus();
				}
				break;
			case ' ':
				if (!boardGenerated) {
					generateBoard();
					boardGenerated = 1;
				}
				if (boardStatus[cursor] == HIDDEN && revealField(cursor) == MINE) {
					//game over
					gameOver = 1;
				} else {
					updateCursor();
				}
				break;
		}
	}
	if (gameOver) {
		showMines();
	}
	vt100_set_cursor(boardHeight + 4, 1);
	vt100_show_cursor();
	return 0;
}
