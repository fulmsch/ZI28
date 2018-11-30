#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <readline/readline.h>

void console(const char* format, ...)
{
	va_list args;
	char buffer[100];

	va_start(args, format);
	vsnprintf(buffer, 100, format, args);
	va_end(args);

//	// Readline magic from https://stackoverflow.com/a/15541914
//	int saved_point = rl_point;
//	char *saved_line = rl_copy_text(0, rl_end);
//	rl_save_prompt();
//	rl_replace_line("", 0);
//	rl_redisplay();

	printf("%s", buffer);

//	rl_restore_prompt();
//	rl_replace_line(saved_line, 0);
//	rl_point = saved_point;
//	rl_redisplay();
//	free(saved_line);
}
