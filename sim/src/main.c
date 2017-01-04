#include <stdio.h>
#include <stdarg.h>
#include <gtk/gtk.h>
#include <termios.h>
#include <pty.h>
#include <stdlib.h>
#include <poll.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/time.h>
//#include <time.h>
#include <z80.h>

#include "main.h"
#include "emulator.h"
#include "sd.h"

int quit_req = 0;
GtkTextView *g_view_console;
GtkEntry *g_field_main[7];
GtkEntry *g_field_reg_ix, *g_field_reg_iy;
GtkEntry *g_field_reg_sp, *g_field_reg_pc;
GtkTextBuffer *g_txt_console;

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
	char str[3];
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
}

int main(int argc, char **argv) {
	int hflag = 0;
	int rflag = 0;
	char *romFile;
	int c;
	while ((c = getopt(argc, argv, "hr:")) != -1) {
		switch (c) {
			case 'h':
				hflag = 1;
				break;
			case 'r':
				rflag = 1;
				romFile = optarg;
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


	GtkBuilder   *builder; 
	GtkWidget    *window;

	gtk_init(&argc, &argv);

	builder = gtk_builder_new();
	gtk_builder_add_from_file (builder, "glade/window_main.glade", NULL);

	window = GTK_WIDGET(gtk_builder_get_object(builder, "window_main"));
	gtk_builder_connect_signals(builder, NULL);

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

	g_view_console = GTK_TEXT_VIEW(gtk_builder_get_object(builder, "view_console"));
	gtk_text_view_set_monospace(g_view_console, TRUE);
	g_txt_console = gtk_text_view_get_buffer(GTK_TEXT_VIEW(g_view_console));

	g_object_unref(builder);

	gtk_widget_show(window);


//	struct timeval tv1, tv2;
//	struct timespec sleeptime, remtime;

	while (!quit_req) {
		//gettimeofday(&tv1, NULL);
		if(status == RUN || status == CONT) {
			emulator_runCycles(8000);
			gtk_main_iteration_do(FALSE);
		} else {
			updateRegisters();
			gtk_main_iteration_do(TRUE);
		}
		//gettimeofday(&tv2, NULL);
		//long int dtime = tv2.tv_usec - tv1.tv_usec;
		//printf("%ld\n", dtime);
		//if (dtime > 0) {
		//	sleeptime.tv_nsec = dtime * 1000000;
		//	nanosleep(&sleeptime, &remtime);
		//}
	}
	fclose(sd.imgFile);
	remove("/tmp/zi28sim");

	return 0;

}

// called when window is closed
void quit_application() {
	quit_req = 1;
}

void on_Run_clicked() {
	console("Running...\n");
	status = RUN;
}

void on_Continue_clicked() {
	console("Running...\n");
	status = CONT;
}

void on_Pause_clicked() {
	console("Paused at: 0x%04X\n", context.PC);
	status = PAUSE;
};

void on_Step_clicked() {
	console("Step\n");
	emulator_runCycles(1);
}

void on_Reset_clicked() {
	console("Reset\n");
	emulator_reset();
}
