#ifndef MAIN_H
#define MAIN_H

extern int romProtect;
extern char *sdFileName;

void init_emulator(void);
void console(const char* format, ...);

#endif
