TARGET := vga.so

.PHONY: all clean distclean

all: $(TARGET)

$(TARGET): vga.c
	gcc -Wall -shared -fPIC -o $@ -I. $< `pkg-config --cflags lua53` `sdl2-config --libs --cflags` -O3

clean:

distclean: clean
	@$(RM) -f $(TARGET)
