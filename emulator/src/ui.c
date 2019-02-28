#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <readline/readline.h>

#include "ui.h"

void console(const char* format, ...)
{
	va_list args;

	va_start(args, format);
	vprintf(format, args);
	va_end(args);
}


void printInstruction(Z80Context *context)
{
	char str[20];
	Z80Debug(context, NULL, str);
	console("0x%04X  %s\n", context->PC, str);
}
