#ifndef UI_H
#define UI_H

enum cursorDirection {
	UP,
	DOWN,
	LEFT,
	RIGHT,
};

void showMines(void);
void drawField(int field);
void drawInitialBoard(void);
void drawLine(unsigned char *data, unsigned int n);
void hideGameCursor(void);
void updateCursor(void);
int moveCursor(enum cursorDirection dir);
void printStatus(void);

#endif
