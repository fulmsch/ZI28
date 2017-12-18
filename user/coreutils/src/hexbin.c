#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

//TODO buffer multiple records before writing

//#define DEBUG

#define BUFFER_SIZE 512

int i;
long unsigned int totalCount;
char *inFileName;
char *outFileName;
char inBuffer[BUFFER_SIZE];
char outBuffer[BUFFER_SIZE];
char header[8];
int checkSumCalc, checkSumRead;
unsigned char dataLength, recordType;

unsigned char hexToInt(char *str) {
	unsigned char in, out;
	in = str[0];
	if (in >= 0x40)
		out = (in - 55) << 4;
	else
		out = (in - 0x30) << 4;
	in = str[1];
	if (in >= 0x40)
		out += in - 55;
	else
		out += in - 0x30;
	return out;
}



int main(int argc, char **argv) {
	FILE *inFile = stdin;
	FILE *outFile = stdout;
	char c;
	opterr = 0;

	while ((c = getopt(argc, argv, "hi:o:")) != -1) {
		switch (c) {
			case 'i':
				inFileName = optarg;
				break;
			case 'o':
				outFileName = optarg;
				break;
			case 'h':
				printf("Usage:\n\tHEXBIN [options]\n");
				printf("Options:\n");
				printf("\t-i\tInput file. Default: stdin.\n");
				printf("\t-o\tOutput file. Default: stdout.\n");
				return 0;
			case '?':
				if (optopt == 'i' || optopt == 'o') {
					fprintf (stderr, "%s: Option '-%c' requires an argument.\n", argv[0], optopt);
				} else if (isprint (optopt)) {
					fprintf (stderr, "%s: Unknown option '-%c'.\n", argv[0], optopt);
				} else {
					fprintf (stderr, "%s: Unknown option character '\\x%x'.\n", argv[0], optopt);
				}
				fprintf (stderr, "Type '%s -h' for more information.\n", argv[0]);
				return 1;
			default:
				abort ();
		}
	}

	//Try to open input/output files if specified
	if (inFileName && !(inFile = fopen(inFileName, "r"))) {
		fprintf(stderr, "%s: File '%s' could not be opened for reading.\n", argv[0], inFileName);
		return 2;
	}
	if (outFileName && !(outFile = fopen(outFileName, "w"))) {
		fprintf(stderr, "%s: File '%s' could not be opened for writing.\n", argv[0], outFileName);
		return 3;
	}

	while (1) {
		while ((c = fgetc(inFile)) != ':') {
			//fprintf(stderr, "c=%d\n", c);
			if (c == EOF)
				return 7;
		}
		if (fread(header, 8, 1, inFile) != 1)
			return 4;

		recordType = hexToInt(&header[6]);
#ifdef DEBUG
		fprintf(stderr, "recordType: %d\n", recordType);
#endif
		switch (recordType) {
			case 0x00:
				checkSumCalc = 0;
				for (i = 0; i < 4; i++) {
					checkSumCalc += hexToInt(&header[i*2]);
				}
				dataLength = hexToInt(header);
				if (fread(inBuffer, dataLength * 2 + 2, 1, inFile) != 1) {
#ifdef DEBUG
					fprintf(stderr, "Read error.\n");
#endif
					return 5;
				}
				for (i = 0; i < dataLength; i++) {
					outBuffer[i] = hexToInt(&inBuffer[i*2]);
					checkSumCalc += outBuffer[i];
				}
				checkSumRead = hexToInt(&inBuffer[dataLength * 2]);
				checkSumCalc = (-checkSumCalc) & 0xff;
				if (checkSumCalc != checkSumRead){
					fprintf(stderr, "calc %d, read %d\n", checkSumCalc, checkSumRead);
					return 6;
				}
				totalCount += dataLength * fwrite(outBuffer, dataLength, 1, outFile);
				break;
			case 0x01:
				//last record
				while (fgetc(inFile) != EOF);
				fprintf(stderr, "\n%d bytes written.\n", totalCount);
				return 0;
			default:
				break;
		}
	}
}
