TARGET=zi28sim
SRCDIR=src
INCDIR=include

#compiler
CC=gcc
# debug
DEBUG=-g
# optimisation
OPT=-O0
# warnings
WARN=-Wall

PTHREAD=-pthread

CCFLAGS=$(DEBUG) $(OPT) $(WARN) $(PTHREAD) -I$(INCDIR) -pipe

GTKLIB=`pkg-config --cflags --libs gtk+-3.0`

# linker
LD=gcc
LDFLAGS=$(PTHREAD) $(GTKLIB) -export-dynamic
LIBS=-lz80 -lncurses -lutil

OBJS=main.o emulator.o sd.o

all: $(OBJS)
	$(LD) -o $(TARGET) $(OBJS) $(LDFLAGS) $(LIBS)

main.o: $(SRCDIR)/main.c
	$(CC) -c $(CCFLAGS) $(SRCDIR)/main.c $(GTKLIB) -o main.o

emulator.o: $(SRCDIR)/emulator.c
	$(CC) -c $(CCFLAGS) $(SRCDIR)/emulator.c -o emulator.o

sd.o: $(SRCDIR)/sd.c
	$(CC) -c $(CCFLAGS) $(SRCDIR)/sd.c -o sd.o

clean:
	rm -f *.o
