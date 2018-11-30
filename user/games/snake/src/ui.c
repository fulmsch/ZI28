#include <assert.h>

#include <stdio.h>
#include <sys/stat.h>
#include "main.h"
#include "game.h"
#include "vt100.h"
#include "ui.h"

void drawGrid()
{
	int i;
	for (i = 0; i < grid_width * grid_height; i++) {
		grid[i].type == EMPTY || updateField(i);
	}
}

void updateField(int field)
{
	vt100_set_cursor((field / grid_width) + 1, (field % grid_width * 2) + 1);
	switch (grid[field].type) {
		case EMPTY:
			printf("  ");
			break;
		case FOOD:
			printf("\33[43m  \33[m");
			break;
		case SNAKE:
			printf("\33[42m  \33[m");
			break;
		case SNAKE_HEAD:
			printf("\33[42m  \33[m");
			break;
		case BORDER:
			printf("\33[7m  \33[m");
			break;
		case COLLISION:
			printf("\33[41m  \33[m");
			break;
		default:
			break;
	}
	/*
	vt100_set_cursor((field / grid_width) + 1, (field % grid_width) + 1);
	switch (grid[field].type) {
		case EMPTY:
			putchar(' ');
			break;
		case FOOD:
			printf("\33[31m$\33[m");
			break;
		case SNAKE:
			printf("\33[32mo\33[m");
			break;
		case SNAKE_HEAD:
			printf("\33[32m@\33[m");
			break;
		case BORDER:
			printf("\33[7m#\33[m");
			break;
		case COLLISION:
			printf("\33[31mX\33[m");
			break;
		default:
			break;
	}
	*/
}

void showScore(int score)
{
	vt100_set_cursor(grid_height + 2, 1);
	printf("\33[KScore: %d", score);
}
