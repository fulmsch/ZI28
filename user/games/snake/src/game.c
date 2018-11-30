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


int gameOver, score;
int grid_width = 32, grid_height = 16;

struct field grid[32*16];

static int snake_head, snake_tail;
static int snake_newDir;


static void placeFood(void);

static void snake_moveHead(int newHead);
static void snake_moveTail(int newTail);

void initGame()
{
	int i, j;
	for (i = 0; i < grid_height; i++) {
		for (j = 0; j < grid_width; j++) {
			if (i == 0 || i == (grid_height - 1) ||
			    j == 0 || j == (grid_width - 1)) {
				grid[i*grid_width + j].type = BORDER;
			}
		}
	}
	gameOver = 0;
	score = 0;
	snake_head = (grid_width / 2) + (grid_height / 2 * grid_width);
	snake_tail = snake_head;
	grid[snake_head].type = SNAKE_HEAD;
	placeFood();
	drawGrid();
	showScore(score);
}

void snake_setDir(enum cursorDir dir)
{
	char d;
	switch (dir) {
		case UP:
			d = -grid_width;
			break;
		case DOWN:
			d = grid_width;
			break;
		case LEFT:
			d = -1;
			break;
		case RIGHT:
			d = 1;
			break;
		default:
			d = 0;
			return;
	}
	if (grid[snake_head].dir != -d) {
		snake_newDir = d;
	}
}

void snake_move()
{
	int newHead, newTail;
	if (snake_newDir) {
		grid[snake_head].dir = snake_newDir;
		snake_newDir = 0;
	}
	if (grid[snake_head].dir == 0) return;
	newHead = snake_head + grid[snake_head].dir;
	newTail = snake_tail + grid[snake_tail].dir;

	switch (grid[newHead].type) {
		case SNAKE:
			if (newHead == snake_tail) {
				snake_moveTail(newTail);
				snake_moveHead(newHead);
				return;
			}
		case BORDER:
			//game over
			grid[newHead].type = COLLISION;
			grid[snake_head].type = SNAKE;
			snake_moveTail(newTail);
			updateField(snake_head);
			updateField(newHead);
			gameOver = 1;
			return;
		case FOOD:
			placeFood();
			snake_moveHead(newHead);
			score++;
			showScore(score);
			return;
		default:
			snake_moveHead(newHead);
			snake_moveTail(newTail);
			return;
	}
}

static void snake_moveHead(int newHead)
{
	grid[newHead].dir = grid[snake_head].dir;
	grid[newHead].type = SNAKE_HEAD;
	grid[snake_head].type = SNAKE;
	updateField(snake_head);
	updateField(newHead);
	snake_head = newHead;
}

static void snake_moveTail(int newTail)
{
	grid[snake_tail].type = EMPTY;
	updateField(snake_tail);
	snake_tail = newTail;
}

static void placeFood()
{
	int field;
	do {
		field = rand() % (grid_width * grid_height);
	} while (grid[field].type != EMPTY);
	grid[field].type = FOOD;
	updateField(field);
}
