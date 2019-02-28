#ifndef UI_H
#define UI_H

#include "libz80/z80.h"

void console(const char* format, ...);
void printInstruction(Z80Context *context);

#endif
