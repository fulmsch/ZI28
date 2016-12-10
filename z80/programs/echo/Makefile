INCLUDEPATH = ../../includes

echo.hex: echo.asm $(INCLUDEPATH)/*.h
	naken_asm -b echo.asm -o echo.obj -I $(INCLUDEPATH)
	srec_cat echo.obj -binary -o echo.hex -intel
