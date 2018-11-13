#ifndef GAME_H
#define GAME_H

#define CUR_PIECE(i) (curPiece[i + curRot * 16])

void initGame(void);

void softDrop(void);
void hardDrop(void);
void moveLeft(void);
void moveRight(void);
void rotateLeft(void);
void rotateRight(void);

extern char board[200];
extern int curX, curY;
extern char *curPiece;
extern char *nextPiece;
extern unsigned int curRot;
extern unsigned int level;
extern unsigned long int score;
extern unsigned int lines;
extern int speed[30];

#endif
