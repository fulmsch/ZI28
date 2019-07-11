#include <stdio.h>
#include <string.h>

unsigned int i, y, x;
uint8_t color;

int main(int argc, char **argv) {
	// Clear the screen
	outp(0x93, 0); // Set x and y register to 0
	for (i = 0; i < (256 * 192); i++) {
		outp(0x97, 0x00);
	}
	
	// Draw 1px white border
	outp(0x93, 0); // Set x and y register to 0
	for (i = 0; i < 128; i++) {
		outp(0x97, 0xff);
	}

	for (i = 1; i < 191; i++) {
		outp(0x92, i); //y

		outp(0x91, 0); //x
		outp(0x96, 0x0f);

		outp(0x91, 127); //x
		outp(0x96, 0xf0);
	}

	outp(0x92, 191); //y
	outp(0x91, 0); //x
	for (i = 0; i < 128; i++) {
		outp(0x97, 0xff);
	}


	for (y = 74; y < 118; y++) {
		outp(0x92, y);
		outp(0x91, 23);
		for (x = 0; x < 82; x++) {
			outp(0x97, 0xff);
		}
	}

	// Draw all colors
	for (i = 0; i < 8; i++) {
		color = i | (i << 4);
		for (y = 76; y < 116; y++) {
			outp(0x91, 24 + (i * 10));
			outp(0x92, y);
			for (x = 0; x < 10; x++) {
				outp(0x97, color | (y < 96 ? 0 : 0x88));
			}
		}
	}
}
