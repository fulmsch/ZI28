include ../../Make.config

ASMFILES = $(wildcard *.asm)
CFILES = $(wildcard *.c)

OBJECTS = $(ASMFILES:.asm=.o) $(CFILES:.c=.o)

all: $(OBJECTS)

%.o: %.c
	zcc +zi28 $(CFLAGS) -o $@  $^

%.o: %.asm
	zcc +zi28 $(CFLAGS) -o $@  $^

clean:
	$(RM) -fr *.o
