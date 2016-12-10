INCLUDEPATH = ../../includes

tictactoe.hex: tictactoe.asm $(INCLUDEPATH)/*.h
	naken_asm tictactoe.asm -o tictactoe.hex -I $(INCLUDEPATH) && \
	srec_cat tictactoe.hex -intel -o tictactoe.obj -binary && \
	cp tictactoe.obj TICTACTO.COM
