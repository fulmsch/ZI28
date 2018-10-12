#ifndef GAME_H
#define GAME_H

enum cursorDir {
	UP,
	DOWN,
	LEFT,
	RIGHT
};

enum fieldType {
	EMPTY = 0,
	FOOD,
	SNAKE,
	SNAKE_HEAD,
	BORDER,
	COLLISION
};

struct field {
	enum fieldType type;
	char dir;
};

extern int grid_width, grid_height;
extern int gameOver, score;
extern struct field grid[];

void initGame(void);
void snake_setDir(enum cursorDir dir);
void snake_move(void);

#endif
