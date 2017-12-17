#include <stdlib.h>
#include <stdio.h>
#include "main.h"
#include "game.h"
#include "ui.h"

int cursor = 0;
int hiddenFields, unflaggedMines;
int boardWidth, boardHeight, totalMines;
enum fieldContent boardContent[EXPERT_HEIGHT * EXPERT_WIDTH]; //TODO dynamic allocation
enum fieldStatus boardStatus[EXPERT_HEIGHT * EXPERT_WIDTH]; //TODO dynamic allocation

static enum fieldContent getFieldContent(int field) {
	int i, j, index;
	enum fieldContent total = NONE;

	if (boardContent[field] == MINE) return MINE;

	for (i = -1; i <= 1; i++) {
		if ((field % boardWidth + i < 0) || (field % boardWidth + i >= boardWidth))
			continue;
		for (j = -1; j <= 1; j++) {
			if ((field / boardWidth + j < 0) || (field / boardWidth + j >= boardHeight))
				continue;
			index = field + i + (boardWidth * j);
			if (boardContent[index] == MINE)
				total++;
		}
	}
	return total;
}

enum fieldContent revealField(int field) {
	int i, j, index;
	if (boardStatus[field] != HIDDEN)
		return NONE;
	else
		hiddenFields--;
	boardStatus[field] = REVEALED;
	drawField(field);

	for (i = -1; i <= 1; i++) {
		if ((field % boardWidth + i < 0) || (field % boardWidth + i >= boardWidth))
			continue;
		for (j = -1; j <= 1; j++) {
			if ((field / boardWidth + j < 0) || (field / boardWidth + j >= boardHeight))
				continue;
			index = field + i + (boardWidth * j);
			if (boardContent[index] == NONE || boardContent[field] == NONE)
				revealField(index);
		}
	}
	
	return boardContent[field];
}

void generateBoard() {
	int i, index;
	//clear board
	for (i = 0; i < boardWidth * boardHeight; i++) {
		boardContent[i] = NONE;
//		boardStatus[i] = REVEALED;
		boardStatus[i] = HIDDEN;
	}
	//fill board with mines
	for (i = 0; i < totalMines; i++) {
		do {
			index = rand() % (boardWidth * boardHeight);
		} while (boardContent[index] == MINE || index == cursor);
		boardContent[index] = MINE;
	}
	//calculate all numbers
	for (i = 0; i < boardWidth * boardHeight; i++) {
		boardContent[i] = getFieldContent(i);
	}
//	for (i = 0; i < boardWidth * boardHeight; i++) {
//		drawField(i);
//	}
}
