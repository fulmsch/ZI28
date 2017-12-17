#include <assert.h>

#include <stdio.h>
#include <sys/stat.h>
#include "main.h"
#include "game.h"
#include "vt100.h"
#include "ui.h"


static void gotoCursor(int cursor);
static void gotoField(int field);
static unsigned int oldPos;

static void drawTopLine(unsigned int width) {
	putchar('+');
	width = width * 2 + 1;
	while (width --> 0) putchar('-');
	putchar('+');
	putchar('\n');
}

void drawField(int field) {
	gotoField(field);
	if (boardStatus[field] == HIDDEN) {
		puts("\33[C-");
//		putchar('-');
		return;
	} else if (boardStatus[field] == FLAGGED) {
		puts("\33[CF");
//		putchar('F');
		return;
	}
	switch (boardContent[field]) {
		case NONE:
//			putchar(' ');
			puts("\33[7m   \33[0m");
			return;
		case ONE:
			//cyan
//			puts("\33[36m1\33[0m");
			puts("\33[7;44m 1 \33[0m");
			return;
		case TWO:
			//green
//			puts("\33[32m2\33[0m");
			puts("\33[7;42m 2 \33[0m");
			return;
		case THREE:
			//red
//			puts("\33[31m3\33[0m");
			puts("\33[7;41m 3 \33[0m");
			return;
		case FOUR:
			//magenta
//			puts("\33[35m4\33[0m");
			puts("\33[7;45m 4 \33[0m");
			return;
		case FIVE:
			//yellow
//			puts("\33[33m5\33[0m");
			puts("\33[7;43m 5 \33[0m");
			return;
		case SIX:
			//cyan
//			puts("\33[36m6\33[0m");
			puts("\33[7;46m 6 \33[0m");
			return;
		case SEVEN:
			//blue + bold
//			puts("\33[1;34m7\33[0m");
			puts("\33[7;1;44m 7 \33[0m");
			return;
		case EIGHT:
			//red + bold
//			puts("\33[1;31m8\33[0m");
			puts("\33[7;1;41m 8 \33[0m");
			return;
		case MINE:
//			puts("\33[1;31mX\33[0m");
			puts("\33[41m X \33[0m");
			return;
		default:
			return;
	}
}

void showMines() {
	int i;
	for (i = 0; i < boardWidth * boardHeight; i++) {
		if (boardContent[i] == MINE) {
			gotoField(i);
			if (boardStatus[i] == FLAGGED)
				puts("\33[41m F \33[0m");
			else
				puts("\33[41m X \33[0m");
		} else if (boardStatus[i] == FLAGGED) {
			gotoField(i);
			puts("\33[C\33[31mF\33[0m");
		}
	}
}

void drawInitialBoard(unsigned int width, unsigned int height) {
	int i;
	drawTopLine(width);
	while (height --> 0) {
		putchar('|');
		putchar(' ');
		for (i = 0; i < width; i++) {
			putchar('-');
			putchar(' ');
		}
		putchar('|');
		putchar('\n');
	}
	drawTopLine(width);
	printStatus();
}

void hideGameCursor() {
	gotoCursor(oldPos);
	if (boardStatus[oldPos] == REVEALED) {
		printf("\33[7m \33[C \33[0m");
	} else {
		if (oldPos % boardWidth > 0 && boardStatus[oldPos - 1] == REVEALED) {
			printf("\33[7m");
		}
		printf(" \33[0m\33[C");
		if (oldPos % boardWidth < boardWidth - 1 && boardStatus[oldPos + 1] == REVEALED) {
			printf("\33[7m \33[0m");
		} else {
			printf(" ");
		}
	}
}

void updateCursor() {
	hideGameCursor();
	gotoCursor(cursor);
	if (boardStatus[cursor] == REVEALED) {
		printf("\33[7m<\33[C>\33[0m");
	} else {
		if (cursor % boardWidth > 0 && boardStatus[cursor - 1] == REVEALED) {
			printf("\33[7m");
		}
		printf("<\33[0m\33[C");
		if (cursor % boardWidth < boardWidth - 1 && boardStatus[cursor + 1] == REVEALED) {
			printf("\33[7m>\33[0m");
		} else {
			printf(">");
		}
	}
	oldPos = cursor;
}

int moveCursor(enum cursorDirection dir) {
	//returns 0 if no move happened
	switch(dir) {
		case UP:
			if (cursor >= boardWidth) {
				cursor -= boardWidth;
				break;
			} else {
				return 0;
			}
		case DOWN:
			if (cursor < boardWidth * (boardHeight - 1)) {
				cursor += boardWidth;
				break;
			} else {
				return 0;
			}
		case LEFT:
			if (cursor % boardWidth > 0) {
				cursor -= 1;
				break;
			} else {
				return 0;
			}
		case RIGHT:
			if (cursor % boardWidth < boardWidth - 1) {
				cursor += 1;
				break;
			} else {
				return 0;
			}
		default:
			return 0;
	}
	updateCursor();
}

void printStatus(void) {
	vt100_set_cursor(boardHeight + 3, 1);
	printf("Mines: Total %3d, Unflagged %3d | Time: %3d", totalMines, unflaggedMines, 0);
}

static void gotoCursor(int cursor) {
	int row, col;
	row = cursor / boardWidth + 2;
	col = (cursor % boardWidth) * 2 + 2;
	vt100_set_cursor(row, col);
}

static void gotoField(int field) {
	int row, col;
	row = field / boardWidth + 2;
	col = (field % boardWidth) * 2 + 2;
	vt100_set_cursor(row, col);
}
