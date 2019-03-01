#ifndef GAME_H
#define GAME_H

extern int cursor;
extern int board[81];

void setField(int val);
int loadPuzzle(void);
void resetPuzzle(void);
int checkField(int field);
int checkBoard(void);

#endif
