INCLUDEPATH = ../../includes

echo.hex: echo.asm $(INCLUDEPATH)/*.h
	naken_asm echo.asm -o echo.hex -I $(INCLUDEPATH)
	srec_cat echo.hex -intel -o echo.obj -binary
