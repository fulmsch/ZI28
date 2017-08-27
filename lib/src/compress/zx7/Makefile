#

include ../../Make.config

TARGET ?= test
ASMFILES = $(wildcard *.asm)

OBJECTS = $(GENOBJECTS) $(CUSTOBJECTS) $(ASMFILES:.asm=.o)

.PHONY: 

all: dirs $(addprefix obj/z80/, $(OBJECTS)) $(addprefix obj/ixiy/,$(OBJECTS))

obj/z80/%.o: %.c
	zcc +$(TARGET) $(CFLAGS) -o $@  $^

obj/z80/%.o: %.asm
	zcc +$(TARGET) $(CFLAGS) -o $@  $^

obj/ixiy/%.o: %.c
	zcc +$(TARGET) -Ca--IXIY $(CFLAGS) -o $@  $^

obj/ixiy/%.o: %.asm
	zcc +$(TARGET) -Ca--IXIY $(CFLAGS) -o $@  $^

dirs:
	@mkdir -p obj/z80 obj/r2k obj/ixiy

clean:
	$(RM) -fr obj zcc_opt.def
