INCLUDEPATH = ../../includes

tictactoe.hex: tictactoe.asm $(INCLUDEPATH)/*.h
	naken_asm -b tictactoe.asm -o tictactoe.obj -I $(INCLUDEPATH) && \
	cp tictactoe.obj TICTACTO.COM && \
	srec_cat tictactoe.obj -binary -o tictactoe.hex -intel
