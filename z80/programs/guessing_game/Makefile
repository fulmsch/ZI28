INCLUDEPATH = ../../includes

guessing_game.hex: guessing_game.asm $(INCLUDEPATH)/*.h
	naken_asm guessing_game.asm -o guessing_game.hex -I $(INCLUDEPATH) && \
	srec_cat guessing_game.hex -intel -o guessing_game.obj -binary && \
	cp guessing_game.obj GUESS.COM
