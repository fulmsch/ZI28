
include ../Make.config

TARGET ?= test
GENOBJECTS = assert.o
ASMFILES = $(wildcard *.asm)

OBJECTS = $(GENOBJECTS) $(ASMFILES:.asm=.o)

all: dirs $(addprefix obj/z80/, $(OBJECTS)) $(addprefix obj/ixiy/,$(OBJECTS)) 

obj/z80/%.o: %.c
	zcc +test -mz80 $(CFLAGS) -o $@  $^

obj/z80/%.o: %.asm
	zcc +test -mz80 $(CFLAGS) -o $@  $^

obj/ixiy/%.o: %.c
	zcc +test -mz80 -Ca--IXIY -Cl--IXIY $(CFLAGS) -o $@  $^

obj/ixiy/%.o: %.asm
	zcc +test -mz80 -Ca--IXIY -Cl--IXIY $(CFLAGS) -o $@  $^

obj/$(TARGET)/%.o: %.c
	zcc +$(TARGET) $(CFLAGS) -o $@  $^

obj/$(TARGET)/%.o: %.asm
	zcc +$(TARGET) $(CFLAGS) -o $@  $^

dirs:
	@mkdir -p obj/z80 obj/ixiy obj/$(TARGET)

clean:
	$(RM) -fr obj
