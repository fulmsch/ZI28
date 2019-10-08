#include <stdio.h>
#include <termios.h>
#include <pty.h>
#include <stdlib.h>
#include <poll.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <getopt.h>
#include <signal.h>

#include "main.h"
#include "ui.h"
#include "interpreter.h"
#include "emulator.h"
#include "libz80/z80.h"
#include "config.h"

int romProtect = 0;

int quit_req = 0;

char *romFileName = NULL;

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
			emu_break();
			break;
		case SIGTERM:
			exit(0);
		case SIGABRT:
			exit(1);
	}
}

void updateRegisters() {
	unsigned char *pReg = &zi28.context.R1.br.A;
	char str[20];
	for (int i = 0; i < 7; i++) {
		sprintf(str, "%02X", *pReg);
		//gtk_entry_set_text(g_field_main[i], str);
		pReg++;
	}

	sprintf(str, "%04X", zi28.context.R1.wr.IX);
	//gtk_entry_set_text(g_field_reg_ix, str);

	sprintf(str, "%04X", zi28.context.R1.wr.IY);
	//gtk_entry_set_text(g_field_reg_iy, str);

	sprintf(str, "%04X", zi28.context.R1.wr.SP);
	//gtk_entry_set_text(g_field_reg_sp, str);

	sprintf(str, "%04X", zi28.context.PC);
	//gtk_entry_set_text(g_field_reg_pc, str);

	Z80Debug(&zi28.context, NULL, str);
	//gtk_entry_set_text(g_field_instruction, str);

	//Flags
	for (int i = 0; i < 8; i++) {
		//gtk_entry_set_text(g_field_flags_main[i], (zi28.context.R1.br.F & (1 << i)) ? "1" : "0");
	}
}


void clearRegisters() {
	for (int i = 0; i < 7; i++) {
		//gtk_entry_set_text(g_field_main[i], "");
	}
	//gtk_entry_set_text(g_field_reg_ix, "");
	//gtk_entry_set_text(g_field_reg_iy, "");
	//gtk_entry_set_text(g_field_reg_sp, "");
	//gtk_entry_set_text(g_field_reg_pc, "");
}

int main(int argc, char **argv) {
	int help_flag = 0;
	int romFile_flag = 0;
	int silent_flag = 0;
	int configFlag = 0;
	int c;
	char *configFile = NULL;
	atexit(cleanup);
	signal(SIGINT, sigHandler);
	signal(SIGTERM, sigHandler);
	signal(SIGABRT, sigHandler);
	while (1) {
		static struct option long_options[] = {
			{"help",      no_argument,       0, 'h'},
			{"text-mode", no_argument,       0, 't'},
			{"rom-file",  required_argument, 0, 'r'},
			{"silent",    no_argument,       0, 's'},
			{"config",    required_argument, 0, 'c'},
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
			case 'r':
				romFile_flag = 1;
				romFileName = optarg;
				break;
			case 's':
				silent_flag = 1;
				break;
			case 'c':
				configFlag = 1;
				configFile = optarg;
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
			" -s, --silent     Don't write anything to stdout.\n"
		);
		return 0;
	}

	if (silent_flag) {
		freopen("/dev/null", "w", stdout);
	}


	//Start z80lib
	emu_init();

	if (!romFile_flag) {
		fprintf(stderr, "Error: No ROM-image specified.\n");
		exit(1);
	}
	if (emu_loadRom(romFileName)) {
		fprintf(stderr, "Error: Could not open '%s'.\n", romFileName);
		exit(1);
	}

	if (!configFlag) {
		char initFileName[] = "init.lua";
		char *configDir = getConfigDir();
		configFile = malloc(strlen(configDir) + strlen(initFileName) + 1);
		strcpy(configFile, configDir);
		strcat(configFile, initFileName);
		free(configDir);
	}
	interpreter_init(configFile);
	if (!configFlag && configFile != NULL) {
		free(configFile);
	}
	interpreter_run();

	return 0;
}
