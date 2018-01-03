#include <stdlib.h>
#include <stdio.h>

int main(int argc, char **argv) {
	unsigned int total, largest;
	void *a, *b, *c, *d;
	mallinfo(&total, &largest);
	printf("Total: %4X, Largest: %4X\n", total, largest);
	printf("a: %p\n", a);
	printf("b: %p\n", b);

	a = malloc(0x10);
	b = malloc(0x10);

	sprintf(a, "test1");
	sprintf(b, "test2");

	mallinfo(&total, &largest);
	printf("Total: %4X, Largest: %4X\n", total, largest);
	printf("a: %p\n", a);
	printf("b: %p\n", b);

	free(a);
	mallinfo(&total, &largest);
	printf("Total: %4X, Largest: %4X\n", total, largest);
	printf("a: %p\n", a);
	printf("b: %p\n", b);

	free(b);
	mallinfo(&total, &largest);
	printf("Total: %4X, Largest: %4X\n", total, largest);
	printf("a: %p\n", a);
	printf("b: %p\n", b);

	return 0;
}
