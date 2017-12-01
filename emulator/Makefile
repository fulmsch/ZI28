TARGET := zi28sim
SRCDIR := src
INCDIR := include

INSTALLDIR := /usr/local/bin

#compiler
CC = gcc
# debug
DEBUG = -g
# optimisation
OPT = -O0
# warnings
WARN = -Wall

PTHREAD = -pthread

CCFLAGS = $(DEBUG) $(OPT) $(WARN) $(PTHREAD) -I$(INCDIR) -pipe

GTKLIB = `pkg-config --cflags --libs gtk+-3.0` `pkg-config --cflags --libs gtkhex-3`

# linker
LD = gcc
LDFLAGS = $(PTHREAD) $(GTKLIB) -export-dynamic
LIBS = -lz80 -lutil

OBJS = main.o resources.o emulator.o sd.o

.PHONY: all clean distclean install

all: zi28sim

zi28sim: $(OBJS)
	$(LD) -o $(TARGET) $(OBJS) $(LDFLAGS) $(LIBS)

install: zi28sim
	cp zi28sim $(INSTALLDIR)/zi28sim && chmod +x $(INSTALLDIR)/zi28sim

src/resources.c: glade/resources.xml glade/window_main.glade
	cd glade && glib-compile-resources --target=../$(SRCDIR)/resources.c --generate-source resources.xml

%.o: $(SRCDIR)/%.c
	$(CC) -c $(CCFLAGS) $(GTKLIB) $< -o $@

clean:
	@$(RM) -f *.o $(SRCDIR)/resources.c

distclean: clean
	@$(RM) -f $(TARGET)

