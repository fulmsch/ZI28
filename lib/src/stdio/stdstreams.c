#include <stdio.h>
#include <unistd.h>

void stdstreams() {
	// Set up stdin, stdout and stderr
	fdopen(STDIN_FILENO, "r");
	fdopen(STDOUT_FILENO, "a");
	fdopen(STDERR_FILENO, "a");
}
