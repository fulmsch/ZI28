INCLUDEPATH = ../../includes

guessing_game.hex: guessing_game.asm $(INCLUDEPATH)/*.h
	naken_asm -b guessing_game.asm -o guessing_game.obj -I $(INCLUDEPATH) && \
	cp guessing_game.obj GUESS.COM && \
	srec_cat guessing_game.obj -binary -o guessing_game.hex -intel
