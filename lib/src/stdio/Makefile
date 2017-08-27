#
# Wahey, a messed up makefile for building libraries!
#
# $Id: Makefile,v 1.61 2016-07-14 13:30:11 pauloscustodio Exp $
#
# 8080

include ../Make.config

CFILES = $(filter-out fflush.c, $(wildcard *.c))
ZSFILES = $(wildcard zsock/*.c) fflush.c
AFILES = $(filter-out asm_printf_core.asm, $(wildcard *.asm))
OFILES = $(CFILES:.c=.o) $(AFILES:.asm=.o)


all: dirs general $(addprefix  obj/,$(OFILES)) $(addprefix obj/ixiy/,$(OFILES)) $(addprefix obj/stdesc/,$(OFILES))

obj/ixiy/%.o: %.asm
	zcc +test $(CFLAGS) -Ca--IXIY -Ca-I../ -c -o $@ $^

obj/ixiy/%.o: %.c
	zcc +test $(CFLAGS) -Ca--IXIY -c -o $@ $^

obj/%.o: %.asm
	zcc +test $(CFLAGS) -Ca-I../ -c -o $@ $^

obj/%.o: %.c
	zcc +test $(CFLAGS) -c -o $@ $^

obj/stdesc/%.o: %.asm
	zcc +test $(CFLAGS) -Ca-DSTANDARDESCAPECHARS -Ca-I../ -Cc-standard-escape-chars -c -o $@ $^

obj/stdesc/%.o: %.c
	zcc +test $(CFLAGS) -Cc-standard-escape-chars -c -o $@ $^




.PHONY: dirs general
dirs:
	@mkdir -p obj obj/net obj/net/zsock obj/ixiy obj/stdesc obj/r2k

general:
	$(MAKE) -C general



ansi-clean:
	$(RM) ansi/*.o ansi/*/*.o

clean:  ansi-clean
	$(RM) *.o* *.sym *.map zcc_opt.def *.i */*.o
	$(RM) -fr obj
