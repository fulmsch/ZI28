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

#include <gtkhex.h>

#include "main.h"
#include "emulator.h"
#include "sd.h"

GResource *resources_get_resource(void);

int quit_req = 0;
GtkTextView *g_view_console;
GtkEntry *g_field_instruction;
GtkEntry *g_field_main[7];
GtkEntry *g_field_flags_main[8];
GtkEntry *g_field_reg_ix, *g_field_reg_iy;
GtkEntry *g_field_reg_sp, *g_field_reg_pc;
GtkEntry *g_field_break;
//GtkButton *g_button_break_add, *g_button_break_rem_all;
GtkTextBuffer *g_txt_console;

gint timeout_update(gpointer data);

GtkWidget    *window;

char *romFile = 0;

int breakpointsEnabled = 1;

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
	char str[20];
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

	//Flags
	for (int i = 0; i < 8; i++) {
		gtk_entry_set_text(g_field_flags_main[i], (context.R1.br.F & (1 << i)) ? "1" : "0");
	}
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

	if (bflag && !rflag) {
		fprintf(stderr, "Error: No ROM-image specified\nUse '-h' for help\n");
		return 1;
	}
//	if (!rflag) {
//		fprintf(stderr, "Missing argument(s)\nUse '-h' for help\n");
//		return 1;
//	}


	//Start z80lib
	emulator_init();
	if (romFile) {
		emulator_loadRom(romFile);
	}

	if (bflag) {
		while (1) {
			Z80Execute(&context);
		}
		fclose(sd.imgFile);
		remove("/tmp/zi28sim");
		return 0;
	}

	g_resources_register(resources_get_resource());

	GtkBuilder *builder; 

	gtk_init(&argc, &argv);

//	builder = gtk_builder_new();
//	gtk_builder_add_from_file (builder, "glade/window_main.glade", NULL);

	builder = gtk_builder_new_from_resource("/zi28sim/window_main.glade");

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

	g_field_flags_main[0] = GTK_ENTRY(gtk_builder_get_object(builder, "field_flag_c"));
	g_field_flags_main[1] = GTK_ENTRY(gtk_builder_get_object(builder, "field_flag_n"));
	g_field_flags_main[2] = GTK_ENTRY(gtk_builder_get_object(builder, "field_flag_pv"));
	g_field_flags_main[3] = GTK_ENTRY(gtk_builder_get_object(builder, "field_flag_3"));
	g_field_flags_main[4] = GTK_ENTRY(gtk_builder_get_object(builder, "field_flag_h"));
	g_field_flags_main[5] = GTK_ENTRY(gtk_builder_get_object(builder, "field_flag_5"));
	g_field_flags_main[6] = GTK_ENTRY(gtk_builder_get_object(builder, "field_flag_z"));
	g_field_flags_main[7] = GTK_ENTRY(gtk_builder_get_object(builder, "field_flag_s"));

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
	if (CONT == status) {
		if (breakpointsEnabled) {
			if (emulator_runCycles(80000, 1)) {
				console("Break at 0x%04X\n", context.PC);
				status = PAUSE;
			}
		} else {
			emulator_runCycles(80000, 0);
		}
	}
	updateRegisters();
	return 1;
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
	status = PAUSE;
	emulator_runCycles(1, 1);
}

void on_Reset_clicked() {
	console("Reset\n");
	emulator_reset();
}

void on_break_enable_toggled(GtkToggleButton *toggle_button) {
	breakpointsEnabled = gtk_toggle_button_get_active(toggle_button);
}

void on_break_add_clicked() {
	const char *str = gtk_entry_get_text(g_field_break);
	char *endptr;
	unsigned int val = strtoul(str, &endptr, 16);
	if ('\0'== *endptr ) {
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

void on_menu_mem_romProtect_toggled(GtkCheckMenuItem *check_menu_item) {
	romProtect = gtk_check_menu_item_get_active(check_menu_item);
	if (romProtect) {
		console("ROM Write-Protection on\n");
	} else {
		console("ROM Write-Protection off\n");
	}
}

void on_menu_mem_romLoad_activate() {
	GtkWidget *dialog;
	gint res;

	dialog = gtk_file_chooser_dialog_new ("Open ROM-Image",
										  GTK_WINDOW(window),
										  GTK_FILE_CHOOSER_ACTION_OPEN,
										  "_Cancel",
										  GTK_RESPONSE_CANCEL,
										  "_Open",
										  GTK_RESPONSE_ACCEPT,
										  NULL);

	res = gtk_dialog_run (GTK_DIALOG (dialog));
	if (res == GTK_RESPONSE_ACCEPT) {
		GtkFileChooser *chooser = GTK_FILE_CHOOSER (dialog);
		romFile = gtk_file_chooser_get_filename (chooser);
		emulator_loadRom(romFile);
		console("Loaded the contents of %s into ROM\n", romFile);
	}

	gtk_widget_destroy (dialog);
}

void on_menu_mem_romReload_activate() {
	if (romFile) {
		emulator_loadRom(romFile);
		console("ROM-File reloaded\n");
	} else {
		console("Warning: No ROM-file specified\n");
	}
}

void on_menu_mem_ramClear_activate() {
	for (int i = 0x4000; i < 0x10000; i++) {
		memory[i] = 0;
	}
	console("RAM cleared\n");
}

void on_menu_mem_ramRand_activate() {
	for (int i = 0x4000; i < 0x10000; i++) {
		memory[i] = rand();
	}
	console("RAM randomized\n");
}

void on_menu_mem_editor_activate() {
	GtkWidget *memEditorWindow = gtk_window_new(GTK_WINDOW_TOPLEVEL);
	HexDocument *hexdoc = hex_document_new();
	hex_document_set_data(hexdoc, 0,
								  0x10000, 0, memory,
								  FALSE);
	GtkWidget *hexeditor = gtk_hex_new(hexdoc);
	gtk_hex_show_offsets(GTK_HEX(hexeditor), TRUE);
	gtk_container_add(GTK_CONTAINER(memEditorWindow), hexeditor);
	gtk_widget_show_all(memEditorWindow);
}
