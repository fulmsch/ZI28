INCLUDEPATH = ../../includes

echo.hex: echo.asm $(INCLUDEPATH)/*.h
	z80asm -v -i echo.asm -o echo.obj -I $(INCLUDEPATH)
	srec_cat echo.obj -binary -o echo.hex -intel
