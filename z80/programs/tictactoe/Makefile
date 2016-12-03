INCLUDEPATH = ../../includes

tictactoe.hex: tictactoe.asm $(INCLUDEPATH)/*.h
	z80asm -v -i tictactoe.asm -o tictactoe.obj -I $(INCLUDEPATH) && \
	cp tictactoe.obj TICTACTO.COM && \
	srec_cat tictactoe.obj -binary -o tictactoe.hex -intel
