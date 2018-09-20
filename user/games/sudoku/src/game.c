#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>
#include "main.h"
#include "game.h"
#include "ui.h"

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
	char buf[81];
	struct stat statBuf;
	fd = open("/DATA/SUDOKU/0.SDM", O_RDONLY, 0);
	fstat(fd, &statBuf);
	lines = statBuf.st_size / 82L;
	lseek(fd, ((off_t) rand() % lines) * 82L, SEEK_SET);
	read(fd, buf, 81);
	close(fd);
	for (i = 0; i < 81; i++) {
		board[i] = 0 - (buf[i] - '0');
	}
}
