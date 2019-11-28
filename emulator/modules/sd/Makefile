TARGET := sd.so

.PHONY: all clean distclean

all: $(TARGET)

$(TARGET): sd.c
	gcc -Wall -shared -fPIC -o $@ -I. $< `pkg-config --cflags lua53`

clean:

distclean: clean
	@$(RM) -f $(TARGET)
