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

void addMine(int field) {
	int i, j, index;

	boardContent[field] = MINE;

	for (i = -1; i <= 1; i++) {
		if ((field % boardWidth + i < 0) || (field % boardWidth + i >= boardWidth))
			continue;
		for (j = -1; j <= 1; j++) {
			if ((field / boardWidth + j < 0) || (field / boardWidth + j >= boardHeight))
				continue;
			index = field + i + (boardWidth * j);
			if (boardContent[index] != MINE)
				boardContent[index]++;
		}
	}
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
		boardStatus[i] = HIDDEN;
	}
	//fill board with mines
	for (i = 0; i < totalMines; i++) {
		do {
			index = rand() % (boardWidth * boardHeight);
		} while (boardContent[index] == MINE || index == cursor);
		addMine(index);
	}
}
