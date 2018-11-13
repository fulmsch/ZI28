#include <assert.h>
#include <string.h>
#include <stdio.h>
#include <sys/stat.h>
#include "main.h"
#include "game.h"
#include "vt100.h"
#include "ui.h"

static char newBoard[200];
static char oldBoard[200];
static char outString[1024];

void initUI()
{
	int i;
	memset(oldBoard, sizeof(oldBoard), 0);
	vt100_clear_screen();
	vt100_hide_cursor();
	vt100_set_cursor(0, 0);

	// Draw border around board
	vt100_set_cursor(2, 3);
	printf("\33[7m                        ");
	for (i = 0; i < 20; i++) {
		vt100_set_cursor(3 + i, 3);
		printf("  ");
		vt100_set_cursor(3 + i, 25);
		printf("  ");
	}
	vt100_set_cursor(23, 3);
	printf("                        \33[m");

	// Draw border around next piece
	vt100_set_cursor(2, 31);
	printf("\33[7m            ");
	for (i = 0; i < 4; i++) {
		vt100_set_cursor(3 + i, 31);
		printf("  ");
		vt100_set_cursor(3 + i, 41);
		printf("  ");
	}
	vt100_set_cursor(7, 31);
	printf("            \33[m");
	updateNextDisplay();
	updateScore(0);
}

void updateBoard()
{
	int i, x, y;
	char *lineIndex = outString;
	int prevX;
	int prevColor;
	int firstInLine;
	// Build new board
	memcpy(newBoard, board, sizeof(newBoard));
	if (curPiece) {
		for (i = 0; i < 16; i++) {
			if (!CUR_PIECE(i)) continue;
			x = (curX + i % 4);
			y = (curY + i / 4);
			newBoard[x + 10 * y] = CUR_PIECE(i);
		}
	}

	prevColor = -1;

	for (y = 0; y < 20; y++) {
		firstInLine = 1;
		for (x = 0; x < 10; x++) {
			i = x + y * 10;
			if (newBoard[i] != oldBoard[i]) {
				oldBoard[i] = newBoard[i];
				if (firstInLine) {
					lineIndex += sprintf(lineIndex, "\33[%d;%dH", 3 + y, 5 + 2 * x);
					firstInLine = 0;
				} else if (x > prevX + 1) {
					lineIndex += sprintf(lineIndex, "\33[%dC", 2 * (x - prevX - 1));
				}
				if (prevColor != newBoard[i]) {
					lineIndex += sprintf(lineIndex,"\33[4%dm", newBoard[i]);
					prevColor = newBoard[i]
				}
				lineIndex += sprintf(lineIndex, "  ");
				prevX = x;
			}
		}
	}
	sprintf(lineIndex, "\33[m");
	printf("%s", outString);
}

void updateNextDisplay()
{
	int i;
	for (i = 0; i < 16; i++) {
		vt100_set_cursor(3 + (i / 4), 33 + 2 * (i % 4));
		printf("\33[4%dm  \33[m", nextPiece[i]);
	}
}

void updateScore()
{
	vt100_set_cursor(10, 31);
	printf("Score:%10ld", score);
	vt100_set_cursor(12, 31);
	printf("Level:%10d", level);
	vt100_set_cursor(14, 31);
	printf("Lines:%10d", lines);
}
