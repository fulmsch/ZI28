include ../../Make.config

CFILES = $(wildcard *.c)
AFILES = $(wildcard *.asm)
OFILES = $(CFILES:.c=.o) $(AFILES:.asm=.o)


all: $(addprefix  ../obj/,$(OFILES))

../obj/%.o: %.asm
	zcc +test $(CFLAGS) -Ca-I../ -c -o $@ $^

../obj/%.o: %.c
	zcc +test $(CFLAGS) -c -o $@ $^
