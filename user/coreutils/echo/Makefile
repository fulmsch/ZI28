INCLUDEPATH = ../../includes

echo.hex: echo.asm $(INCLUDEPATH)/*.h
	naken_asm -b echo.asm -o echo.obj -I $(INCLUDEPATH)
	objcopy -I binary -O ihex $(TARGET) echo.hex
