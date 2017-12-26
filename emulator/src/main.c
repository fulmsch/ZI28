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
#include <getopt.h>

#include <gtkhex.h>

#include "main.h"
#include "emulator.h"
#include "sd.h"
#include "libz80/z80.h"

GResource *resources_get_resource(void);

int textMode_flag = 0;
int romProtect = 0;

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
GtkWidget    *window_about;

char *romFileName = NULL;
char *sdFileName  = NULL;

int breakpointsEnabled = 1;

enum {
	PAUSE,
	RUN,
	CONT
} status;


void cleanup() {
	remove("/tmp/zi28tty");
}

void sigHandler(int sig) {
	switch (sig) {
		case SIGINT:
		case SIGTERM:
			exit(0);
		case SIGABRT:
			exit(1);
	}
}

void console(const char* format, ...) {
	va_list args;
	char buffer[100];

	va_start(args, format);
	vsnprintf(buffer, 100, format, args);
	va_end(args);

	if (textMode_flag) {
		printf("%s", buffer);
	} else {
		GtkTextIter endIter;
		gtk_text_buffer_get_end_iter(g_txt_console, &endIter);
		gtk_text_buffer_place_cursor(g_txt_console, &endIter);
		gtk_text_buffer_insert_at_cursor(g_txt_console, buffer, -1);
		gtk_text_view_scroll_mark_onscreen (g_view_console,
		                                    gtk_text_buffer_get_insert(g_txt_console));
	}
}

void updateRegisters() {
	unsigned char *pReg = &zi28.context.R1.br.A;
	char str[20];
	for (int i = 0; i < 7; i++) {
		sprintf(str, "%02X", *pReg);
		gtk_entry_set_text(g_field_main[i], str);
		pReg++;
	}

	sprintf(str, "%04X", zi28.context.R1.wr.IX);
	gtk_entry_set_text(g_field_reg_ix, str);

	sprintf(str, "%04X", zi28.context.R1.wr.IY);
	gtk_entry_set_text(g_field_reg_iy, str);

	sprintf(str, "%04X", zi28.context.R1.wr.SP);
	gtk_entry_set_text(g_field_reg_sp, str);

	sprintf(str, "%04X", zi28.context.PC);
	gtk_entry_set_text(g_field_reg_pc, str);

	Z80Debug(&zi28.context, NULL, str);
	gtk_entry_set_text(g_field_instruction, str);

	//Flags
	for (int i = 0; i < 8; i++) {
		gtk_entry_set_text(g_field_flags_main[i], (zi28.context.R1.br.F & (1 << i)) ? "1" : "0");
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
	int help_flag = 0;
	int romFile_flag = 0;
	int silent_flag = 0;
	int c;
	atexit(cleanup);
	signal(SIGINT, sigHandler);
	signal(SIGTERM, sigHandler);
	signal(SIGABRT, sigHandler);
	while (1) {
		static struct option long_options[] = {
			{"help",      no_argument,       0, 'h'},
			{"text-mode", no_argument,       0, 't'},
			{"rom-file",  required_argument, 0, 'r'},
			{"sd-image",  required_argument, 0, 'c'},
			{"silent",    no_argument,       0, 's'},
			{0, 0, 0, 0}
		};
		int option_index = 0;
		c = getopt_long(argc, argv, "htr:c:s",
		                long_options, &option_index);

		// End of options
		if (c == -1) break;

		switch (c) {
			case 'h':
				help_flag = 1;
				break;
			case 't':
				textMode_flag = 1;
				break;
			case 'r':
				romFile_flag = 1;
				romFileName = optarg;
				break;
			case 'c':
				sdFileName = optarg;
				break;
			case 's':
				silent_flag = 1;
				break;
			case '?':
				fprintf(stderr, "Invalid invocation.\nUse '--help' for help.\n");
				return 1;
			default:
				return 1;
		}
	}

	if (help_flag) {
		printf(
			"Usage: zi28sim [options]\n"
			"Options:\n"
			" -h, --help       Display this help message.\n"
			" -t, --text-mode  Launch without a graphical interface.\n"
			" -r, --rom-file   Specify a binary file that is loaded into ROM.\n"
			" -c, --sd-image   Specify a SD-Card image file.\n"
			" -s, --silent     Don't write anything to stdout.\n"
		);
		return 0;
	}

	if (silent_flag) {
		freopen("/dev/null", "w", stdout);
	}


	//Start z80lib
	emulator_init();

	if (!textMode_flag && !gtk_init_check(&argc, &argv)) {
		fprintf(stderr, "Warning: Cannot open display.\n"
		                "Executing in text mode.\n");
		freopen("/dev/null", "w", stdout);
		silent_flag = 1;
		textMode_flag = 1;
	}

	if (textMode_flag) {
		if (!romFile_flag) {
			fprintf(stderr, "Error: No ROM-image specified.\n");
			exit(1);
		}
		if (emulator_loadRom(romFileName)) {
			fprintf(stderr, "Error: Could not open '%s'.\n", romFileName);
			exit(1);
		}
		while (1) {
			Z80Execute(&zi28.context);
		}
	}

	g_resources_register(resources_get_resource());

	GtkBuilder *builder; 

	builder = gtk_builder_new_from_resource("/zi28sim/window_main.glade");

	window = GTK_WIDGET(gtk_builder_get_object(builder, "window_main"));
	window_about = GTK_WIDGET(gtk_builder_get_object(builder, "window_about"));
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

	if (romFileName) {
		if (emulator_loadRom(romFileName)) {
			console("Warning: Could not open '%s'.\n", romFileName);
		}
	}

	gtk_main();

	return 0;
}

gint timeout_update(gpointer data) {
	if (CONT == status) {
		if (breakpointsEnabled) {
			if (emulator_runCycles(80000, 1)) {
				console("Break at 0x%04X.\n", zi28.context.PC);
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
	console("Paused at: 0x%04X.\n", zi28.context.PC);
	status = PAUSE;
};

void on_Step_clicked() {
	status = PAUSE;
	emulator_runCycles(1, 1);
}

void on_Reset_clicked() {
	console("System reset.\n");
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
			console("Added breakpoint at address 0x%04X.\n", val);
		} else {
			console("There's already a breakpoint at address 0x%04X.\n", val);
		}
	} else {
		console("Invalid address.\n");
	}
}

void on_break_rem_all_clicked() {
	memset(&breakpoints[0], 0, sizeof(breakpoints));
}

void on_menu_mem_romProtect_toggled(GtkCheckMenuItem *check_menu_item) {
	romProtect = gtk_check_menu_item_get_active(check_menu_item);
	if (romProtect) {
		console("ROM Write-Protection on.\n");
	} else {
		console("ROM Write-Protection off.\n");
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
		romFileName = gtk_file_chooser_get_filename (chooser);
		if (!emulator_loadRom(romFileName))
			console("Loaded the contents of '%s' into ROM.\n", romFileName);
		else
			console("Could not open '%s'.\n", romFileName);
	}

	gtk_widget_destroy (dialog);
}

void on_menu_mem_romReload_activate() {
	if (romFileName) {
		if (!emulator_loadRom(romFileName))
			console("Could not open '%s'.\n", romFileName);
		else
			console("ROM-File reloaded.\n");
	} else {
		console("Warning: No ROM-file specified.\n");
	}
}

void on_menu_mem_ramClear_activate() {
	for (int i = 0; i < 0x20000; i++) {
		zi28.ram[i] = 0;
	}
	console("RAM cleared.\n");
}

void on_menu_mem_ramRand_activate() {
	for (int i = 0; i < 0x20000; i++) {
		zi28.ram[i] = rand();
	}
	console("RAM randomized.\n");
}

void on_menu_mem_editor_activate() {
	/*
	GtkWidget *memEditorWindow = gtk_window_new(GTK_WINDOW_TOPLEVEL);
	HexDocument *hexdoc = hex_document_new();
	hex_document_set_data(hexdoc, 0,
								  0x10000, 0, memory,
								  FALSE);
	GtkWidget *hexeditor = gtk_hex_new(hexdoc);
	gtk_hex_show_offsets(GTK_HEX(hexeditor), TRUE);
	gtk_container_add(GTK_CONTAINER(memEditorWindow), hexeditor);
	gtk_widget_show_all(memEditorWindow);
	*/
}

void on_menu_help_about_activate() {
	gtk_dialog_run(GTK_DIALOG(window_about));
	gtk_widget_hide(window_about);
}
