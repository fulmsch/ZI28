#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>
#include <string.h>
#include <errno.h>
#include "main.h"
#include "game.h"
#include "ui.h"
#include "vt100.h"


char board[200];

static char piece_I[64] = {0,0,0,0, 6,6,6,6, 0,0,0,0, 0,0,0,0,
                           0,0,6,0, 0,0,6,0, 0,0,6,0, 0,0,6,0,
                           0,0,0,0, 6,6,6,6, 0,0,0,0, 0,0,0,0,
                           0,0,6,0, 0,0,6,0, 0,0,6,0, 0,0,6,0};
static char piece_O[64] = {0,0,0,0, 0,3,3,0, 0,3,3,0, 0,0,0,0,
                           0,0,0,0, 0,3,3,0, 0,3,3,0, 0,0,0,0,
                           0,0,0,0, 0,3,3,0, 0,3,3,0, 0,0,0,0,
                           0,0,0,0, 0,3,3,0, 0,3,3,0, 0,0,0,0};
static char piece_S[64] = {0,0,0,0, 0,0,2,2, 0,2,2,0, 0,0,0,0,
                           0,0,2,0, 0,0,2,2, 0,0,0,2, 0,0,0,0,
                           0,0,0,0, 0,0,2,2, 0,2,2,0, 0,0,0,0,
                           0,0,2,0, 0,0,2,2, 0,0,0,2, 0,0,0,0};
static char piece_Z[64] = {0,0,0,0, 0,1,1,0, 0,0,1,1, 0,0,0,0,
                           0,0,0,1, 0,0,1,1, 0,0,1,0, 0,0,0,0,
                           0,0,0,0, 0,1,1,0, 0,0,1,1, 0,0,0,0,
                           0,0,0,1, 0,0,1,1, 0,0,1,0, 0,0,0,0};
static char piece_J[64] = {0,0,0,0, 0,4,4,4, 0,0,0,4, 0,0,0,0,
                           0,0,4,0, 0,0,4,0, 0,4,4,0, 0,0,0,0,
                           0,4,0,0, 0,4,4,4, 0,0,0,0, 0,0,0,0,
                           0,0,4,4, 0,0,4,0, 0,0,4,0, 0,0,0,0};
static char piece_L[64] = {0,0,0,0, 0,7,7,7, 0,7,0,0, 0,0,0,0,
                           0,7,7,0, 0,0,7,0, 0,0,7,0, 0,0,0,0,
                           0,0,0,7, 0,7,7,7, 0,0,0,0, 0,0,0,0,
                           0,0,7,0, 0,0,7,0, 0,0,7,7, 0,0,0,0};
static char piece_T[64] = {0,0,0,0, 0,5,5,5, 0,0,5,0, 0,0,0,0,
                           0,0,5,0, 0,5,5,0, 0,0,5,0, 0,0,0,0,
                           0,0,5,0, 0,5,5,5, 0,0,0,0, 0,0,0,0,
                           0,0,5,0, 0,0,5,5, 0,0,5,0, 0,0,0,0};

static char *pieces[] = {piece_I, piece_O, piece_S, piece_Z, piece_J, piece_L, piece_T};

static int checkCollision();
static void lockPiece();

int speed[30] = {800, 717, 633, 550, 466, 383, 300, 217, 133, 100, 83, 83, 83, 67, 67, 67, 50, 50, 50, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33, 17};

int curX, curY;
unsigned int curRot;
char *curPiece, *nextPiece;
unsigned long int score;
unsigned int level = 20;
unsigned int lines;


void initGame()
{
	int i, j;
	// Clear the board
	memset(board, sizeof(board), 0);
	nextPiece = pieces[rand() % 7];
	curRot = 0;
	score = 0;
	lines = 0;
	initUI();
}

void softDrop()
{
	if (!curPiece) {
		curPiece = nextPiece;
		nextPiece = pieces[rand() % 7];
		updateNextDisplay();
		curRot = 0;
		curX = 3;
		curY = -1;
		if (checkCollision()) {
			updateBoard();
			quit(0);
		}
	} else {
		curY += 1;
		if (checkCollision()) {
			curY -= 1;
			lockPiece();
		}
	}
	updateBoard();
}

void hardDrop()
{
	if (!curPiece) return;
	do {
		curY += 1;
	} while (!checkCollision());
	curY -= 1;
	lockPiece();
	updateBoard();
}

void moveLeft()
{
	curX -= 1;
	if (checkCollision()) {
		curX += 1;
		return;
	}
	updateBoard();
}

void moveRight()
{
	curX += 1;
	if (checkCollision()) {
		curX -= 1;
		return;
	}
	updateBoard();
}

void rotateLeft()
{
}

void rotateRight()
{
	curRot = (curRot + 1) % 4;
	if (checkCollision()) {
		curRot = (curRot - 1) % 4;
		return;
	}
	updateBoard();
}

static int checkCollision()
{
	int i, x, y;
	for (i = 0; i < 16; i++) {
		if (!CUR_PIECE(i)) continue;
		x = (curX + i % 4);
		y = (curY + i / 4);
		if (x < 0 || x >= 10 || y < 0 || y >= 20) return 1; // Out of bounds
		if (board[x + 10 * y]) return 1; // Collision
	}
	return 0;
}

static void lockPiece()
{
	int i, j, x, y;
	int cleared = 0;
	for (i = 0; i < 16; i++) {
		if (!CUR_PIECE(i)) continue;
		x = (curX + i % 4);
		y = (curY + i / 4);
		board[x + 10 * y] = CUR_PIECE(i);
	}
	curPiece = NULL;
	updateBoard();
	// Clear full lines
	for (i = 0; i < 20; i++) {
		for (j = 0; j < 10; j++) {
			if (!board[j + 10 * i]) break;
		}
		if (j < 10) continue;
		// Clear line i
		memmove(board + 10, board, i * 10);
		cleared++;
	}
	switch (cleared) {
		case 1:
			score += 40 * (level + 1);
			break;
		case 2:
			score += 100 * (level + 1);
			break;
		case 3:
			score += 300 * (level + 1);
			break;
		case 4:
			score += 1200 * (level + 1);
			break;
		default:
			break;
	}
	lines += cleared;
	level += cleared;
	updateScore(score);
}
