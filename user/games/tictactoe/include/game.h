#ifndef GAME_H
#define GAME_H

typedef enum {
	PLAYER_X = -1,
	NONE = 0,
	PLAYER_O = 1,
} player_t;

typedef struct {
	player_t board[9];
	int cursorPos;
	player_t currentPlayer;
	int turn;
	int players;
	int difficulty;
} game_t;

player_t checkWinner(player_t *b);
void playGame(game_t *game, player_t first);
void resetGame(game_t *game);

#endif
