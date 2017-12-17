#include <stdio.h>
#include <stdlib.h>
#include "game.h"
#include "ai.h"
#include "ui.h"

void getMove(game_t *game);

player_t checkWinner(player_t *b)
{
	int i;
	for (i = 0; i < 3; i++) {
		//Check horizontals
		if (b[i*3] && b[i*3 + 1] == b[i*3] && b[i*3 + 2] == b[i*3])
			return b[i*3];
		//Check verticals
		if (b[i] && b[3 + i] == b[i] && b[6 + i] == b[i])
			return b[i];
	}
	if (!b[4]) return NONE;

	//Check diagonals
	if (b[4] == b[0] && b[8] == b[0]) return b[0];
	if (b[4] == b[6] && b[2] == b[4]) return b[4];

	return NONE;
}

void resetGame(game_t *game) {
	int i;
	for (i = 0; i < 9; i++) {
		game->board[i] = NONE;
	}
	game->cursorPos = 4;
	game->turn = 0;
	game->currentPlayer = PLAYER_X;
}

void playGame(game_t *game, player_t first) {
	char c;
	int i;
	player_t winner;
	resetGame(game);
	game->currentPlayer = first;
	for (i = 0; i < 9; i++) {
		drawScreen(game);
		getMove(game);
		winner = checkWinner(game->board);
		if (winner != NONE) {
			break;
		}
		game->currentPlayer = -game->currentPlayer;
		game->turn++;
	}

	drawScreen(game);
	putchar('\n');
	if (winner == PLAYER_X) {
		printf("Player X wins!\n");
	} else if (winner == PLAYER_O) {
		printf("Player O wins!\n");
	} else {
		printf("It's a draw!\n");
	}
}

void getMove(game_t *game) {
	char c;
	if ((game->players == 1 && game->currentPlayer == PLAYER_O)
			|| game->players == 0) {
		game->board[getBestMove(game)] = game->currentPlayer;
		return;
	}
	while (1) {
		c = getchar();
		switch (c) {
			case 0x03:
				exit(0);
			case 'w':
				if (game->cursorPos > 2) game->cursorPos -= 3;
				break;
			case 'a':
				if (game->cursorPos % 3 > 0) game->cursorPos -= 1;
				break;
			case 's':
				if (game->cursorPos < 6) game->cursorPos += 3;
				break;
			case 'd':
				if (game->cursorPos % 3 < 2) game->cursorPos += 1;
				break;
			case 0x0a:
				if (game->board[game->cursorPos] == NONE) {
					game->board[game->cursorPos] = game->currentPlayer;
					return;
				}
		}
		drawScreen(game);
	}
}
