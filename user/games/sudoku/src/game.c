#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>
#include <errno.h>
#include "main.h"
#include "game.h"
#include "ui.h"
#include "vt100.h"

int cursor = 0;
int board[81];

void setField(int val)
{
	if (board[cursor] >= 0) {
		board[cursor] = val;
		drawField(cursor);
	}
}

int loadPuzzle()
{
	int fd, i;
	off_t lines;
//	static off_t offset = 32636;
	static off_t offset = 15580;
	char buf[81];
	struct stat statBuf;
	fd = open("/DATA/SUDOKU/3.SDM", O_RDONLY, 0);
	fstat(fd, &statBuf);
	lines = statBuf.st_size / (off_t) 82;
//	lines = 1000;
//	offset = ((off_t) rand() % lines) * 82;
	offset += 82;
	vt100_set_cursor(16, 1);
	printf("offset: %ld -> %ld", offset, lseek(fd, offset, SEEK_SET));
	errno = 0;
	//read(fd, buf, 81);
	printf(", ret: %d, err: %d", read(fd, buf, 81), errno);
	close(fd);
	for (i = 0; i < 81; i++) {
		board[i] = 0 - (buf[i] - '0');
	}
}

void resetPuzzle()
{
	int i;
	for (i = 0; i < 81; i++)
		if (board[i] > 0) board[i] = 0;
}

int checkField(int field)
{
	//check if the specified field contains a valid number
	//output:
	//-1 -> invalid
	// 0 -> empty
	// 1 -> valid

	int fieldval, i, j, row, col, curField, squareY, squareX;

	fieldval = abs(board[field]);
	if (fieldval == 0)
		return 0;

	row = field / 9;
	col = field % 9;
	squareY = row / 3;
	squareX = col / 3;

	//check row
	curField = row * 9;
	for (i = 0; i < 9; i++) {
		if (abs(board[curField]) == fieldval && curField != field) {
			return -1;
		}
		curField++;
	}

	//check column
	curField = col;
	for (i = 0; i < 9; i++) {
		if (abs(board[curField]) == fieldval && curField != field) {
			return -1;
		}
		curField += 9;
	}

	//check square
	curField = squareY * 3 * 9 + squareX * 3;
	for (i = 0; i < 3; i++) {
		for (j = 0; j < 3; j++) {
			if (abs(board[curField]) == fieldval && curField != field) {
				return -1;
			}
			curField++;
		}
		curField += 9 - 3;
	}
	return 1;
}

int checkBoard()
{
	int i, ret;
	for (i = 0; i < 81; i++) {
		ret = checkField(i);
		if (ret <= 0) return ret;
	}
	return 1;
}
