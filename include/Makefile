.PHONY: all clean distclean

all: sys/os.h sys/iomap.h errno.h z80asm/os.h z80asm/iomap.h z80asm/errno.h

sys/os.h: asm/os.h
	@echo '#ifndef OS_H' > sys/os.h
	@echo '#define OS_H' >> sys/os.h
	@echo '' >> sys/os.h
	@sed -e 's/\(\w\+\)\s\+equ\s\+\(\w\+\)/\#define \1 \2/' -e 's/;/\/\//g' asm/os.h >> sys/os.h
	@echo '' >> sys/os.h
	@echo '#endif' >> sys/os.h

sys/iomap.h: asm/iomap.h
	@echo '#ifndef IOMAP_H' > sys/iomap.h
	@echo '#define IOMAP_H' >> sys/iomap.h
	@echo '' >> sys/iomap.h
	@sed -e 's/DEFC\s\+\(\w\+\)\s\+=\s\+\(\w\+\)/\#define \1 \2/' -e 's/;/\/\//g' -e '/^\(IFNDEF\|DEFINE\|ENDIF\)/d' asm/iomap.h >> sys/iomap.h
	@echo '' >> sys/iomap.h
	@echo '#endif' >> sys/iomap.h

errno.h: asm/errno.h
	@echo '#ifndef ERRNO_H' > errno.h
	@echo '#define ERRNO_H' >> errno.h
	@echo '' >> errno.h
	@echo 'extern int errno;' >> errno.h
	@echo '' >> errno.h
	@sed -e 's/DEFC\s\+\(\w\+\)\s\+=\s\+\(\w\+\)/\#define \1 \2/' -e 's/;/\/\//g' -e '/^\(IFNDEF\|DEFINE\|ENDIF\)/d' asm/errno.h >> errno.h
	@echo '' >> errno.h
	@echo '#endif' >> errno.h


z80asm/os.h: asm/os.h
	@mkdir -p z80asm
	@sed -e 's/#define\s\+\(\w\+\)\s\+\(\w\+\)/\DEFC \1 = \2/' asm/os.h >> z80asm/os.h

z80asm/iomap.h: asm/iomap.h
	@mkdir -p z80asm
	@sed -e 's/#define\s\+\(\w\+\)\s\+\(\w\+\)/\DEFC \1 = \2/' asm/os.h >> z80asm/iomap.h

z80asm/errno.h: asm/errno.h
	@mkdir -p z80asm
	@sed -e 's/#define\s\+\(\w\+\)\s\+\(\w\+\)/\DEFC \1 = \2/' asm/os.h >> z80asm/errno.h


clean:

distclean:
	$(RM) -rf z80asm sys/os.h sys/iomap.h errno.h
