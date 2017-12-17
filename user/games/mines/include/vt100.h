#ifndef VT100_H
#define VT100_H

int vt100_get_status(void);
void vt100_clear_screen(void);
void vt100_set_cursor(int row, int column);
void vt100_hide_cursor();
void vt100_show_cursor();

#endif
