TARGET := zi28emu
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

CCFLAGS = $(DEBUG) $(OPT) $(WARN) $(PTHREAD) -I$(INCDIR) -I. -pipe

GTKLIB = `pkg-config --cflags --libs gtk+-3.0`

# linker
LD = gcc
LDFLAGS = $(PTHREAD) $(GTKLIB) -export-dynamic
LIBS = -lutil

OBJS = main.o resources.o emulator.o sd.o libz80/libz80.o

.PHONY: all clean distclean install

all: $(TARGET)

$(TARGET): $(OBJS)
	$(LD) -o $(TARGET) $(OBJS) $(LDFLAGS) $(LIBS)

install: $(TARGET)
	install $(TARGET) $(INSTALLDIR)

src/resources.c: glade/resources.xml glade/window_main.glade
	cd glade && glib-compile-resources --target=../$(SRCDIR)/resources.c --generate-source resources.xml

%.o: $(SRCDIR)/%.c
	$(CC) -c $(CCFLAGS) $(GTKLIB) $< -o $@

clean:
	@$(RM) -f *.o $(SRCDIR)/resources.c libz80/libz80.o \
	          libz80/codegen/mktables libz80/codegen/opcodes_decl.h \
	          libz80/codegen/opcodes_table.h libz80/codegen/opcodes_impl.c

distclean: clean
	@$(RM) -f $(TARGET)


# --- libz80 ---
libz80/libz80.o: libz80/z80.c libz80/z80.h \
                 libz80/codegen/opcodes_table.h \
                 libz80/codegen/opcodes_decl.h \
                 libz80/codegen/opcodes_impl.c
	$(CC) -c $(CCFLAGS) -o $@ libz80/z80.c

libz80/codegen/opcodes_table.h \
libz80/codegen/opcodes_impl.c: libz80/codegen/mktables \
                               libz80/codegen/opcodes.lst \
                               libz80/codegen/mktables.spec
	cd libz80/codegen && ./mktables

libz80/codegen/opcodes_decl.h: libz80/codegen/opcodes_impl.c
	grep "static void" $< | sed "s/)/);/g" > $@

libz80/codegen/mktables: libz80/codegen/mktables.c
	gcc -g -o $@ $<
