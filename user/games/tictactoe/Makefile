INCLUDEPATH = ../../include

tictactoe.hex: tictactoe.asm $(INCLUDEPATH)/*.h
	naken_asm -b tictactoe.asm -o TICTACTO.EX8 -I $(INCLUDEPATH) && \
	cp TICTACTO.EX8 ../../sysroot/GAMES/TICTACTO.EX8 && \
	objcopy -I binary -O ihex tictactoe.obj tictactoe.hex
