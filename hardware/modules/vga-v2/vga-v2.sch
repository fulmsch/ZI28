EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 4
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L Mechanical:MountingHole_Pad H102
U 1 1 5DF0E8A7
P 2750 4700
AR Path="/5DF0E8A7" Ref="H102"  Part="1" 
AR Path="/5DF06544/5DF0E8A7" Ref="H?"  Part="1" 
F 0 "H102" H 2850 4703 50  0000 L CNN
F 1 "MountingHole_Pad" H 2850 4658 50  0001 L CNN
F 2 "MountingHole:MountingHole_3.2mm_M3_Pad" H 2750 4700 50  0001 C CNN
F 3 "~" H 2750 4700 50  0001 C CNN
	1    2750 4700
	1    0    0    -1  
$EndComp
$Comp
L Mechanical:MountingHole_Pad H101
U 1 1 5DF0E8B9
P 2300 4700
AR Path="/5DF0E8B9" Ref="H101"  Part="1" 
AR Path="/5DF06544/5DF0E8B9" Ref="H?"  Part="1" 
F 0 "H101" H 2400 4703 50  0000 L CNN
F 1 "MountingHole_Pad" H 2400 4658 50  0001 L CNN
F 2 "MountingHole:MountingHole_3.2mm_M3_Pad" H 2300 4700 50  0001 C CNN
F 3 "~" H 2300 4700 50  0001 C CNN
	1    2300 4700
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0102
U 1 1 5DF0E8B3
P 2750 4800
AR Path="/5DF0E8B3" Ref="#PWR0102"  Part="1" 
AR Path="/5DF06544/5DF0E8B3" Ref="#PWR?"  Part="1" 
F 0 "#PWR0102" H 2750 4550 50  0001 C CNN
F 1 "GND" H 2755 4627 50  0000 C CNN
F 2 "" H 2750 4800 50  0001 C CNN
F 3 "" H 2750 4800 50  0001 C CNN
	1    2750 4800
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0101
U 1 1 5DF0E8AD
P 2300 4800
AR Path="/5DF0E8AD" Ref="#PWR0101"  Part="1" 
AR Path="/5DF06544/5DF0E8AD" Ref="#PWR?"  Part="1" 
F 0 "#PWR0101" H 2300 4550 50  0001 C CNN
F 1 "GND" H 2305 4627 50  0000 C CNN
F 2 "" H 2300 4800 50  0001 C CNN
F 3 "" H 2300 4800 50  0001 C CNN
	1    2300 4800
	1    0    0    -1  
$EndComp
$Sheet
S 1950 2150 950  1500
U 5E36D68B
F0 "ZI-28 Interface" 50
F1 "interface.sch" 50
F2 "~RST" B R 2900 3400 50 
F3 "LV_D[0..7]" B R 2900 2550 50 
F4 "LV_A[0..3]" O R 2900 2650 50 
F5 "~D_EN" I R 2900 2400 50 
F6 "~INT" I R 2900 3250 50 
F7 "~LV_RD" O R 2900 3000 50 
F8 "~LV_WR" O R 2900 2900 50 
$EndSheet
$Sheet
S 3400 2150 2000 1500
U 5E4BD7CF
F0 "FPGA" 50
F1 "fpga.sch" 50
F2 "~INT" O L 3400 3250 50 
F3 "RED_B1" O R 5400 2450 50 
F4 "RED_B0" O R 5400 2350 50 
F5 "GRN_B0" O R 5400 2600 50 
F6 "GRN_B1" O R 5400 2700 50 
F7 "BLU_B1" O R 5400 2950 50 
F8 "BLU_B0" O R 5400 2850 50 
F9 "~HSYNC" O R 5400 3150 50 
F10 "~VSYNC" O R 5400 3250 50 
F11 "~VGA_EN" O R 5400 3450 50 
F12 "~RST" B L 3400 3400 50 
F13 "~D_EN" O L 3400 2400 50 
F14 "LV_D[0..7]" B L 3400 2550 50 
F15 "LV_A[0..3]" I L 3400 2650 50 
F16 "~LV_WR" I L 3400 2900 50 
F17 "~LV_RD" I L 3400 3000 50 
$EndSheet
$Sheet
S 5900 2150 1000 1500
U 5E03F935
F0 "Output" 50
F1 "output.sch" 50
F2 "RED_B1" I L 5900 2450 50 
F3 "RED_B0" I L 5900 2350 50 
F4 "GRN_B0" I L 5900 2600 50 
F5 "GRN_B1" I L 5900 2700 50 
F6 "BLU_B1" I L 5900 2950 50 
F7 "BLU_B0" I L 5900 2850 50 
F8 "~HSYNC" I L 5900 3150 50 
F9 "~VSYNC" I L 5900 3250 50 
F10 "~VGA_EN" I L 5900 3450 50 
$EndSheet
Wire Wire Line
	5400 2350 5900 2350
Wire Wire Line
	5400 2450 5900 2450
Wire Wire Line
	5400 2600 5900 2600
Wire Wire Line
	5400 2700 5900 2700
Wire Wire Line
	5400 2850 5900 2850
Wire Wire Line
	5400 2950 5900 2950
Wire Wire Line
	5400 3150 5900 3150
Wire Wire Line
	5400 3250 5900 3250
Wire Wire Line
	5400 3450 5900 3450
Wire Wire Line
	2900 2400 3400 2400
Wire Wire Line
	2900 2900 3400 2900
Wire Wire Line
	2900 3000 3400 3000
Wire Wire Line
	2900 3250 3400 3250
Wire Wire Line
	3400 3400 2900 3400
Wire Bus Line
	2900 2550 3400 2550
Wire Bus Line
	2900 2650 3400 2650
$EndSCHEMATC
