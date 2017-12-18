#include <stdlib.h>
#include <stdio.h>
#include "game.h"
#include "ai.h"
#include "ui.h"

const int corners[] = {0, 2, 6, 8};
const int depths[] = {0, 2, 5, 5};

int testMove(player_t *board, player_t player, int depth);

int getBestMove(game_t *game) {
	int bestScore = -100;
	int bestMove = -1;
	int i, j, score;

	if (game->difficulty == 3) {
		if (game->turn == 0)
			return corners[rand() % 4];
		if (game->turn == 1)
			return game->board[4] ? corners[rand() % 4] : 4;
	}

	if (game->difficulty > 0 && game->turn > 1) {
		for (i = 0; i < 9; i++) {
			if (game->board[i]) continue;
			game->board[i] = game->currentPlayer;
			score = testMove(game->board, game->currentPlayer, depths[game->difficulty]);
			game->board[i] = NONE;
			if (score > bestScore) {
				j = 1;
				bestScore = score;
				bestMove = i;
			}/* else if (score == bestScore) {
				if (!(rand() % ++j))
					bestMove = i;
			}*/
		}
	}

	while (bestMove < 0 || game->board[bestMove]) {
		bestMove = rand() % 9;
	}
	return bestMove;
}

int testMove(player_t *board, player_t player, int depth) {
	int i, score;
	int bestScore = 0;
	int worstScore = 0;

	if (!depth) return 0;

	score = checkWinner(board);
	if (score)
		return score == player ? depth : -depth;

	for (i = 0; i < 9; i++) {
		if (board[i]) continue;

		board[i] = -player;
		score = -testMove(board, -player, depth - 1);
		board[i] = NONE;

		if (score > bestScore) bestScore = score;
		if (score < worstScore) worstScore = score;
	}

	return bestScore ? bestScore : worstScore;
}
