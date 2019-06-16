vga.so: vga.c
	gcc -Wall -shared -fPIC -o vga.so -I. vga.c `pkg-config --cflags lua53` `sdl2-config --libs --cflags` -O3
