#include <stdio.h>
#include "game.h"

void clearScreen(void);
void drawField(char *string, int field, game_t *game);
void drawScreen(game_t *game);


void clearScreen() {
	printf("\33[2J\33[H");
}

void drawField(char *string, int field, game_t *game) {
	string[0] = game->cursorPos == field ? '[' : ' ';
	switch (game->board[field]) {
		case PLAYER_X:
			string[1] = 'X';
			break;
		case PLAYER_O:
			string[1] = 'O';
			break;
		case NONE:
			string[1] = ' ';
			break;
		default:
			string[1] = '?';
	}
	string[2] = game->cursorPos == field ? ']' : ' ';
	string[3] = '|';
}

void drawBoard(game_t *game) {
	int i, j;
	char line[12];
	for (i = 0; i < 3; i++) {
		printf("  ");
		for (j = 0; j < 3; j++) {
			drawField(&line[j * 4], i*3 + j, game);
		}
		line[11] = 0;
		printf("%s\n", line);
		if (i < 2) printf("  ---+---+---\n");
	}
}

void drawScreen(game_t *game) {
	clearScreen();
	printf("My wins: %d | Your wins: %d | Draws: %d\n", 0, 0, 0);
	printf("WASD: move cursor, ENTER: confirm\n\n\n");
	drawBoard(game);
	printf("\n\n");
	if (game->players == 1) {
		if (game->currentPlayer == PLAYER_X) printf("Your turn.\n");
		else if (game->currentPlayer == PLAYER_O) printf("My turn. Thinking...\n");
	} else if (game->players == 2) {
		if (game->currentPlayer == PLAYER_X) printf("Player X's turn.\n");
		else if (game->currentPlayer == PLAYER_O) printf("Player O's turn.\n");
	}
}
