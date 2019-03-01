#include <assert.h>

#include <stdio.h>
#include <sys/stat.h>
#include "main.h"
#include "game.h"
#include "vt100.h"
#include "ui.h"


static void gotoCursor(int field);
static void gotoField(int field);
static unsigned int oldPos;

void drawField(int field) {
	gotoField(field);
	if (board[field] > 0) {
		putchar(board[field] + '0');
	} else if (board[field] < 0) {
		printf("\33[1m%c\33[m", -board[field] + '0');
	} else {
		putchar('.');
	}
}

void drawInitialBoard() {
	int i, j;
	vt100_set_cursor(0, 0);
	for (i = 0; i < 4; i++) {
		printf("+-------+-------+-------+\n");
		for (j = 0; j < 3 && i < 3; j++)
			printf("|       |       |       |\n");
	}
	for (i = 0; i < 81; i++) {
		drawField(i);
	}
}

void hideGameCursor() {
	gotoCursor(oldPos);
	printf(" \33[C ");
}

void updateCursor() {
	hideGameCursor();
	gotoCursor(cursor);
	printf("[\33[C]");
	oldPos = cursor;
}

int moveCursor(enum cursorDirection dir) {
	//returns 0 if no move happened
	switch(dir) {
		case UP:
			if (cursor >= 9) {
				cursor -= 9;
				break;
			} else {
				return 0;
			}
		case DOWN:
			if (cursor < 9 * (9 - 1)) {
				cursor += 9;
				break;
			} else {
				return 0;
			}
		case LEFT:
			if (cursor % 9 > 0) {
				cursor -= 1;
				break;
			} else {
				return 0;
			}
		case RIGHT:
			if (cursor % 9 < 9 - 1) {
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

static void gotoCursor(int field) {
	int x, y;
	int row, col;
	x = field % 9;
	y = field / 9;
	col = (x * 2) + (x / 3) * 2 + 2;
	row = y + (y / 3) + 2;
	vt100_set_cursor(row, col);
}

static void gotoField(int field) {
	int x, y;
	int row, col;
	x = field % 9;
	y = field / 9;
	col = (x * 2) + (x / 3) * 2 + 2 + 1;
	row = y + (y / 3) + 2;
	vt100_set_cursor(row, col);
}
