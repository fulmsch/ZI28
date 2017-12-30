.PHONY: all clean distclean

all: sys/os.h errno.h

sys/os.h: asm/os.asm
	@echo '#ifndef OS_H' > sys/os.h
	@echo '#define OS_H' >> sys/os.h
	@echo '' >> sys/os.h
	@sed -e 's/DEFC\s\+\(\w\+\)\s\+=\s\+\(\w\+\)/\#define \1 \2/' -e 's/;/\/\//g' asm/os.asm >> sys/os.h
	@echo '' >> sys/os.h
	@echo '#endif' >> sys/os.h

errno.h: asm/errno.asm
	@echo '#ifndef ERRNO_H' > errno.h
	@echo '#define ERRNO_H' >> errno.h
	@echo '' >> errno.h
	@echo '#ifndef __NAKEN_ASM' >> errno.h
	@echo 'extern int errno;' >> errno.h
	@echo '#endif' >> errno.h
	@echo '' >> errno.h
	@sed -e 's/DEFC\s\+\(\w\+\)\s\+=\s\+\(\w\+\)/\#define \1 \2/' -e 's/;/\/\//g' asm/errno.asm >> errno.h
	@echo '' >> errno.h
	@echo '#endif' >> errno.h

clean:

distclean:
	$(RM) sys/os.h errno.h
