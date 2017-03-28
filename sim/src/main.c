/* TODO
* make frequency adjustable
* count cycles
* log to file
* finish register & breakpoint gui
* memory view / edit
* load file to memory
*/
#include <stdio.h>
#include <stdarg.h>
#include <gtk/gtk.h>
#include <termios.h>
#include <pty.h>
#include <stdlib.h>
#include <poll.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <z80.h>

#include "main.h"
#include "emulator.h"
#include "sd.h"

int quit_req = 0;
GtkTextView *g_view_console;
GtkEntry *g_field_instruction;
GtkEntry *g_field_main[7];
GtkEntry *g_field_reg_ix, *g_field_reg_iy;
GtkEntry *g_field_reg_sp, *g_field_reg_pc;
GtkEntry *g_field_break;
//GtkButton *g_button_break_add, *g_button_break_rem_all;
GtkTextBuffer *g_txt_console;

gint timeout_update(gpointer data);

enum {
	PAUSE,
	RUN,
	CONT
} status;

void console(const char* format, ...) {
	va_list args;
	char buffer[100];

	va_start(args, format);
	vsprintf(buffer, format, args);
	va_end(args);

	gtk_text_buffer_insert_at_cursor(g_txt_console, buffer, -1);
	gtk_text_view_scroll_mark_onscreen (g_view_console,
	                                    gtk_text_buffer_get_insert(g_txt_console));
}

void updateRegisters() {
	unsigned char *pReg = &context.R1.br.A;
	char str[10];
	for (int i = 0; i < 7; i++) {
		sprintf(str, "%02X", *pReg);
		gtk_entry_set_text(g_field_main[i], str);
		pReg++;
	}

	sprintf(str, "%04X", context.R1.wr.IX);
	gtk_entry_set_text(g_field_reg_ix, str);

	sprintf(str, "%04X", context.R1.wr.IY);
	gtk_entry_set_text(g_field_reg_iy, str);

	sprintf(str, "%04X", context.R1.wr.SP);
	gtk_entry_set_text(g_field_reg_sp, str);

	sprintf(str, "%04X", context.PC);
	gtk_entry_set_text(g_field_reg_pc, str);

	Z80Debug(&context, NULL, str);
	gtk_entry_set_text(g_field_instruction, str);
}

void clearRegisters() {
	for (int i = 0; i < 7; i++) {
		gtk_entry_set_text(g_field_main[i], "");
	}
	gtk_entry_set_text(g_field_reg_ix, "");
	gtk_entry_set_text(g_field_reg_iy, "");
	gtk_entry_set_text(g_field_reg_sp, "");
	gtk_entry_set_text(g_field_reg_pc, "");
}

int main(int argc, char **argv) {
	int hflag = 0;
	int rflag = 0;
	int bflag = 0;
	char *romFile;
	int c;
	while ((c = getopt(argc, argv, "hr:b")) != -1) {
		switch (c) {
			case 'h':
				hflag = 1;
				break;
			case 'r':
				rflag = 1;
				romFile = optarg;
				break;
			case 'b':
				bflag = 1;
				break;
			case '?':
				fprintf(stderr, "Invalid invocation\nUse '-h' for help\n");
				return 1;
			default:
				return 1;
		}
	}

	if (hflag) {
		printf("Usage: zi28sim [options] -t terminal -r rom image\n");
		return 0;
	}

	if (!rflag) {
		fprintf(stderr, "Missing argument(s)\nUse '-h' for help\n");
		return 1;
	}


	//Start z80lib
	emulator_init();
	emulator_loadRom(romFile);

	if (bflag) {
		while (1) {
			Z80Execute(&context);
		}
		fclose(sd.imgFile);
		remove("/tmp/zi28sim");
		return 0;
	}


	GtkBuilder   *builder; 
	GtkWidget    *window;

	gtk_init(&argc, &argv);

	builder = gtk_builder_new();
	gtk_builder_add_from_file (builder, "glade/window_main.glade", NULL);

	window = GTK_WIDGET(gtk_builder_get_object(builder, "window_main"));
	gtk_builder_connect_signals(builder, NULL);

	g_field_instruction = GTK_ENTRY(gtk_builder_get_object(builder, "field_instruction"));
	gtk_entry_set_alignment(g_field_instruction, 0.5);

	g_field_main[0] = GTK_ENTRY(gtk_builder_get_object(builder, "field_reg_a"));
	g_field_main[1] = GTK_ENTRY(gtk_builder_get_object(builder, "field_reg_c"));
	g_field_main[2] = GTK_ENTRY(gtk_builder_get_object(builder, "field_reg_b"));
	g_field_main[3] = GTK_ENTRY(gtk_builder_get_object(builder, "field_reg_e"));
	g_field_main[4] = GTK_ENTRY(gtk_builder_get_object(builder, "field_reg_d"));
	g_field_main[5] = GTK_ENTRY(gtk_builder_get_object(builder, "field_reg_l"));
	g_field_main[6] = GTK_ENTRY(gtk_builder_get_object(builder, "field_reg_h"));

	g_field_reg_ix = GTK_ENTRY(gtk_builder_get_object(builder, "field_reg_ix"));
	g_field_reg_iy = GTK_ENTRY(gtk_builder_get_object(builder, "field_reg_iy"));
	g_field_reg_sp = GTK_ENTRY(gtk_builder_get_object(builder, "field_reg_sp"));
	g_field_reg_pc = GTK_ENTRY(gtk_builder_get_object(builder, "field_reg_pc"));

	g_field_break = GTK_ENTRY(gtk_builder_get_object(builder, "field_break"));
//	g_button_break_add = GTK_BUTTON(gtk_builder_get_object(builder, "break_add"));
//	g_button_break_rem_all = GTK_BUTTON(gtk_builder_get_object(builder, "break_rem_all"));

	g_view_console = GTK_TEXT_VIEW(gtk_builder_get_object(builder, "view_console"));
	gtk_text_view_set_monospace(g_view_console, TRUE);
	g_txt_console = gtk_text_view_get_buffer(GTK_TEXT_VIEW(g_view_console));

	g_object_unref(builder);

	gtk_widget_show(window);

	g_timeout_add(10, timeout_update, NULL);

	gtk_main();

	fclose(sd.imgFile);
	remove("/tmp/zi28sim");

	return 0;
}

gint timeout_update(gpointer data) {
	switch (status) {
		case RUN:
			emulator_runCycles(80000, 0);
			break;
		case CONT:
			if (emulator_runCycles(80000, 1)) {
				console("Break at 0x%04X\n", context.PC);
				status = PAUSE;
			}
			break;
		default:
			break;
	}
	updateRegisters();
	return 1;
}

void on_Run_clicked() {
	clearRegisters();
	console("Running...\n");
	status = RUN;
}

void on_Continue_clicked() {
	clearRegisters();
	console("Running...\n");
	status = CONT;
}

void on_Pause_clicked() {
	console("Paused at: 0x%04X\n", context.PC);
	status = PAUSE;
};

void on_Step_clicked() {
	console("Step\n");
	emulator_runCycles(1, 1);
}

void on_Reset_clicked() {
	console("Reset\n");
	emulator_reset();
}

void on_break_add_clicked() {
	unsigned int val;
	const char *str = gtk_entry_get_text(g_field_break);
	if (1 == sscanf(str, "%x", &val)) {
		if (!breakpoints[val]) {
			breakpoints[val] = 1;
			console("Added breakpoint at address 0x%04X\n", val);
		} else {
			console("There's already a breakpoint at address 0x%04X\n", val);
		}
	} else {
		console("Invalid address\n");
	}
}

void on_break_rem_all_clicked() {
	memset(&breakpoints[0], 0, sizeof(breakpoints));
}

void on_menu_file_romProtect_toggled(GtkCheckMenuItem *check_menu_item) {
	romProtect = gtk_check_menu_item_get_active(check_menu_item);
	if (romProtect) {
		console("ROM Write-Protection on\n");
	} else {
		console("ROM Write-Protection off\n");
	}
}
