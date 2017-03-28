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
LIBS=-lz80 -lutil

OBJS=main.o emulator.o sd.o

all: $(OBJS)
	$(LD) -o $(TARGET) $(OBJS) $(LDFLAGS) $(LIBS)

%.o: $(SRCDIR)/%.c
	$(CC) -c $(CCFLAGS) $(GTKLIB) $< -o $@

clean:
	rm -f *.o
