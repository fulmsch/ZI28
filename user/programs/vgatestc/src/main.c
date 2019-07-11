#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/os.h>
#include <errno.h>

int main(int argc, char **argv) {
	uint8_t x, y;
	int i;
	FILE *fp;
	uint8_t *buffer = (uint8_t *)0xC000;

	fp = fopen("/HOME/TEST.IMG", "r");

	outp(0x93, 0); // Set x and y register to 0
	for (y = 0; y < 192; y++) {
		for (x = 0; x < 128; x++) {
			outp(0x97, x);
		}
	}

	outp(0x93, 0); // Set x and y register to 0

	fread(buffer, 1, 0x2000, fp);
	for (i = 0; i < 0x2000; i++) {
		outp(0x97, buffer[i]);
		buffer[i] = 0;
	}

	fread(buffer, 1, 0x4000, fp);
	for (i = 0; i < 0x4000; i++) {
		outp(0x97, buffer[i]);
	}
}
