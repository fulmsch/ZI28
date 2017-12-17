#ifndef GAME_H
#define GAME_H

#define BEGINNER_WIDTH 9
#define BEGINNER_HEIGHT 9
#define BEGINNER_MINES 10

#define INTERMEDIATE_WIDTH 16
#define INTERMEDIATE_HEIGHT 16
#define INTERMEDIATE_MINES 40

#define EXPERT_WIDTH 30
#define EXPERT_HEIGHT 16
#define EXPERT_MINES 99

enum fieldContent {
	NONE = 0,
	ONE = 1,
	TWO = 2,
	THREE = 3,
	FOUR = 4,
	FIVE = 5,
	SIX = 6,
	SEVEN = 7,
	EIGHT = 8,
	MINE = 9
};

enum fieldStatus {
	HIDDEN,
	FLAGGED,
	REVEALED
};

extern int cursor;
extern int hiddenFields, unflaggedMines;
extern int boardWidth, boardHeight, totalMines;
extern enum fieldContent boardContent[EXPERT_HEIGHT * EXPERT_WIDTH]; //TODO dynamic allocation
extern enum fieldStatus boardStatus[EXPERT_HEIGHT * EXPERT_WIDTH]; //TODO dynamic allocation

enum fieldContent revealField(int field);
void generateBoard(void);

#endif
