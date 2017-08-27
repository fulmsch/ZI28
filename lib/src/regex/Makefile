
include ../Make.config

CFILES = regexp.c regsub.c regerror.c

AFILES  = $(CFILES:.c=.opt)
OBJECTS = $(CFILES:.c=.o)

all: dirs $(addprefix obj/z80/, $(OBJECTS)) $(addprefix obj/ixiy/,$(OBJECTS))


dirs:
	@mkdir -p obj/z80 obj/ixiy

obj/ixiy/%.o: %.c
	zcc +test -Ca--IXIY $(CFLAGS) -o $@ -c $^

obj/z80/%.o: %.c
	zcc +test $(CFLAGS) -o $@ -c $^

clean:
	$(RM) *.err *.sym *.map zcc_opt.def *.i $(AFILES)
	$(RM) $(addprefix obj/z80/, $(OBJECTS))
	$(RM) -fr obj
