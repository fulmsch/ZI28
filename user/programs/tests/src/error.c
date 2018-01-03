#include <stdio.h>
#include <string.h>

int i;

int main(int argc, char **argv) {
	printf("Printing all error messages:\n\n");

	for (i = 0; i < 40; i++) {
		printf("%d: %s\n", i, strerror(i));
	}
}
