TARGET := zi28emu
SRCDIR := src
INCDIR := include

MAKEDIRS = $(dir $(shell find modules/ -iname "Makefile"))

INSTALLDIR := /usr/local/bin

#compiler
CC = gcc
# debug
DEBUG = -g
# optimisation
OPT = -O0
# warnings
WARN = -Wall

#PTHREAD = -pthread

CCFLAGS = $(DEBUG) $(OPT) $(WARN) $(PTHREAD) -I$(INCDIR) -I. -pipe `pkg-config --cflags lua53`

# linker
LD = gcc
LDFLAGS = $(PTHREAD) -export-dynamic
LIBS = -lutil -lreadline `pkg-config --libs lua53`

OBJS = main.o config.o ui.o interpreter.o emulator.o luainterface.o libz80/libz80.o

.PHONY: all clean distclean install modules

all: $(TARGET) modules

$(TARGET): $(OBJS)
	$(LD) -o $(TARGET) $(OBJS) $(LDFLAGS) $(LIBS)

install: $(TARGET)
	install $(TARGET) $(INSTALLDIR)

%.o: $(SRCDIR)/%.c
	$(CC) -c $(CCFLAGS) $(GTKLIB) $< -o $@

modules:
	@for DIR in $(MAKEDIRS); do \
		$(MAKE) -C $$DIR --no-print-directory; \
	done

clean:
	@$(RM) -f *.o libz80/libz80.o \
	          libz80/codegen/mktables libz80/codegen/opcodes_decl.h \
	          libz80/codegen/opcodes_table.h libz80/codegen/opcodes_impl.c
	-@for DIR in $(MAKEDIRS); do \
		$(MAKE) -C $$DIR clean --no-print-directory; \
	done

distclean: clean
	@$(RM) -f $(TARGET)
	-@for DIR in $(MAKEDIRS); do \
		$(MAKE) -C $$DIR distclean --no-print-directory; \
	done


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
