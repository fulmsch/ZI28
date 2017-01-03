#include <stdio.h>
#include <gtk/gtk.h>
#include <termios.h>
#include <pty.h>
#include <stdlib.h>
#include <poll.h>
#include <unistd.h>
#include <fcntl.h>
#include <z80.h>

#include "main.h"
#include "emulator.h"
#include "sd.h"

int quit_req = 0;

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

	g_object_unref(builder);

	gtk_widget_show(window);


	while (!quit_req) {
		gtk_main_iteration_do(FALSE);
		Z80Execute(&context);
	}
	fclose(sd.imgFile);
	remove("/tmp/zi28sim");

	return 0;

//	Z80RESET(&context);
}

// called when window is closed
void quit_application() {
	quit_req = 1;
//	gtk_main_quit();
}
