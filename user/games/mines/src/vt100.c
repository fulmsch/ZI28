#include <stdio.h>
#include <string.h>

int vt100_get_status() {
	static const char okString[] = "\33[0n";
	char buffer[4];
	printf("\33[5n");
	fread(buffer, 1, 4, stdin);
	if (strncmp(buffer, okString, 4)) {
		fprintf(stderr, "Terminal device error\n");
		return -1;
	}
	return 0;
}

void vt100_clear_screen() {
	printf("\33[2J\33[H");
}

void vt100_set_cursor(int row, int column) {
	printf("\33[%d;%dH", row, column);
}

void vt100_hide_cursor() {
	printf("\33[?25l");
}

void vt100_show_cursor() {
	printf("\33[?25h");
}
