#include <stdio.h>
#include <stdlib.h>
#include "game.h"
#include "ui.h"

int getPlayers() {
	char c;
	printf("How many players? (1 or 2) ");
	while (1) {
		switch (c = getchar()) {
			case '0':
				printf("0\n");
				return 0;
			case '1':
				printf("1\n");
				return 1;
			case '2':
				printf("2\n");
				return 2;
		}
	}
}

int getDifficulty() {
	char c, d;
	printf("Select difficulty: (0 - 3) ");
	while (1) {
		switch (c = getchar()) {
			case '0':
				d = 0;
				break;
			case '1':
				d = 1;
				break;
			case '2':
				d = 2;
				break;
			case '3':
				d = 3;
				break;
			default:
				continue;
		}
		putchar(c);
		putchar('\n');
		return d;
	}
}

void playAgainPrompt() {
	char c;
	printf("Play again? (Y/n)");
	while (1) {
		switch (c = getchar()) {
			case 'y':
			case 0x0a:
				return;
			case 'n':
			case 0x03:
				putchar('\n');
				exit(0);
		}
	}
}

int main()
{
	int i;
	player_t first = PLAYER_X;
	game_t game;
	printf("Welcome to Tic Tac Toe!\n\n");
	game.players = getPlayers();
	if (game.players == 1) {
		game.difficulty = getDifficulty();
	} else if (game.players == 0) {
		game.difficulty = 3;
		for (i = 0; i < 5; i++) {
			playGame(&game, first);
		}
		printf("\nA strange game.\nThe only winning move is not to play.\n\n");
		return 0;
	}
	while (1) {
		playGame(&game, first);
		playAgainPrompt();
		first = -first;
	}
}
