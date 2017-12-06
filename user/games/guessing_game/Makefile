INCLUDEPATH = ../../../include

guessing_game.hex: guessing_game.asm $(INCLUDEPATH)/*.h
	naken_asm -b guessing_game.asm -o GUESS.EX8 -I $(INCLUDEPATH) && \
	cp GUESS.EX8 ../../sysroot/GAMES/GUESS.EX8 && \
	objcopy -I binary -O ihex guessing_game.bin guessing_game.hex
