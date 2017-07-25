include Make.config

all: genlibs preempt.lib zi28_clib.lib

genlibs: z80_crt0.lib gen_math.lib debug.lib malloc.lib gendos.lib ndos.lib adt.lib balloc.lib \
	 im2.lib rect.lib algorithm.lib


zi28_clib.lib:
	@echo ''
	@echo '--- Building ZI-28 Library ---'
	@echo ''
	$(MAKE) -C strings
	$(MAKE) -C regex
	$(MAKE) -C stdlib TARGET=zi28
	$(MAKE) -C stdio
	$(MAKE) -C compress/zx7
	$(MAKE) -C setjmp
	$(MAKE) -C assert
	TARGET=zi28 TYPE=z80 $(LIBLINKER) -DFORzi28 -DSTANDARDESCAPECHARS -x$(OUTPUT_DIRECTORY)/zi28_clib @$(LISTFILE_DIRECTORY)/zi28.lst

# interesting algorithms - aralbrec
algorithm.lib:
	@echo ''
	@echo '--- Building Algorithm Library ---'
	@echo ''
	$(MAKE) -C algorithm 

# rectangles, intervals and points - aralbrec
rect.lib:
	@echo ''
	@echo '--- Building Rectangles Library ---'
	@echo ''
	$(MAKE) -C rect 

# abstract data types library - aralbrec
adt.lib:
	@echo ''
	@echo '--- Building Abstract Data Types Library ---'
	@echo ''
	$(MAKE) -C adt 

# block memory allocator - aralbrec
balloc.lib:
	@echo ''
	@echo '--- Building Block Memory Allocator Library ---'
	@echo ''
	$(MAKE) -C balloc 

# interrupt mode 2 library - aralbrec
im2.lib:
	@echo ''
	@echo '--- Building IM 2 Library ---'
	@echo ''
	$(MAKE) -C im2 

# Generic maths build - dom, stefano
gen_math.lib:
	@echo ''
	@echo '--- Building Z80 Generic Maths Library ---'
	@echo ''
	$(MAKE) -C math/genmath

# Fast vector 3D library - stefano
lib3d.lib:
	@echo ''
	@echo '--- Building 3D Library ---'
	@echo ''
	$(MAKE) -C lib3d 

# Xlib / X11 and tiny GUI portable library - stefano
x11.lib:
	@echo ''
	@echo '--- Building X11 emulation Library ---'
	@echo ''
	$(MAKE) -C graphics lx11 

# simple malloc library - dom
# adding multiple heaps and realloc - aralbrec
malloc.lib:
	@echo ''
	@echo '--- Building Near Malloc Library ---'
	@echo ''
	$(MAKE) -C malloc 

ndos.lib:
	$(MAKE) -C fcntl/dummy 

gendos.lib:
	$(MAKE) -C fcntl/gen_rnd

# Startup code (such as division etc) common to all z80s - dom
z80_crt0.lib:
	@echo ''
	@echo '--- Building Z80 crt0 Library ---'
	@echo ''
	$(MAKE) -C z80_crt0s 

# Z88DK DEBUG utilities
debug.lib:
	@echo ''
	@echo '--- Building DEBUG Library ---'
	@echo ''
	$(MAKE) -C debug 

# Preempt multitasking library - dom
preempt.lib:
	@echo ''
	@echo '--- Building Preemptive threading Library ---'
	@echo ''
	$(MAKE) -C threading/preempt


clean:
	$(MAKE) -C assert clean
	$(MAKE) -C fcntl clean
	$(MAKE) -C math/genmath clean
#	$(MAKE) -C graphics clean
	$(MAKE) -C malloc clean
	$(MAKE) -C setjmp clean
	$(MAKE) -C stdio clean
	$(MAKE) -C stdlib clean
	$(MAKE) -C strings clean
	$(MAKE) -C regex clean
	$(MAKE) -C z80_crt0s clean
	$(MAKE) -C adt clean
	$(MAKE) -C balloc clean
	$(MAKE) -C im2 clean
	$(MAKE) -C rect clean
	$(MAKE) -C algorithm clean
	$(MAKE) -C debug clean
	$(MAKE) -C lib3d clean
	$(MAKE) -C threading/preempt clean
	$(MAKE) -C math clean
	$(MAKE) -C compress/zx7 clean
	$(RM) $(OUTPUT_DIRECTORY)/*.lib
	$(RM) *.lib
