#ifndef INTERPRETER_H
#define INTERPRETER_H

typedef struct {
	char **argv;
	int argc;
	char *inFile;
	char *outFile;
} commandParam_t;

void interpret(char* line);

#endif
