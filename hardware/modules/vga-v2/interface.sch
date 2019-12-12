EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 2 4
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
L power:+3V3 #PWR?
U 1 1 5E3CCA57
P 8200 4450
AR Path="/5E3CCA57" Ref="#PWR?"  Part="1" 
AR Path="/5E36D68B/5E3CCA57" Ref="#PWR0214"  Part="1" 
F 0 "#PWR0214" H 8200 4300 50  0001 C CNN
F 1 "+3V3" H 8215 4623 50  0000 C CNN
F 2 "" H 8200 4450 50  0001 C CNN
F 3 "" H 8200 4450 50  0001 C CNN
	1    8200 4450
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5E3CCA22
P 8200 5650
AR Path="/5E3CCA22" Ref="#PWR?"  Part="1" 
AR Path="/5DF06544/5E3CCA22" Ref="#PWR?"  Part="1" 
AR Path="/5E36D68B/5E3CCA22" Ref="#PWR0215"  Part="1" 
F 0 "#PWR0215" H 8200 5400 50  0001 C CNN
F 1 "GND" H 8205 5477 50  0000 C CNN
F 2 "" H 8200 5650 50  0001 C CNN
F 3 "" H 8200 5650 50  0001 C CNN
	1    8200 5650
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5E3CCA1C
P 8500 4550
AR Path="/5CE42ADD/5E3CCA1C" Ref="#PWR?"  Part="1" 
AR Path="/5CE42ADD/5CED3C7F/5E3CCA1C" Ref="#PWR?"  Part="1" 
AR Path="/5D235BC5/5E3CCA1C" Ref="#PWR?"  Part="1" 
AR Path="/5E3CCA1C" Ref="#PWR?"  Part="1" 
AR Path="/5DF06544/5E3CCA1C" Ref="#PWR?"  Part="1" 
AR Path="/5E36D68B/5E3CCA1C" Ref="#PWR0216"  Part="1" 
F 0 "#PWR0216" H 8500 4300 50  0001 C CNN
F 1 "GND" V 8505 4422 50  0000 R CNN
F 2 "" H 8500 4550 50  0001 C CNN
F 3 "" H 8500 4550 50  0001 C CNN
	1    8500 4550
	0    -1   -1   0   
$EndComp
$Comp
L Device:C_Small C?
U 1 1 5E3CCA16
P 8400 4550
AR Path="/5CE42ADD/5E3CCA16" Ref="C?"  Part="1" 
AR Path="/5CE42ADD/5CED3C7F/5E3CCA16" Ref="C?"  Part="1" 
AR Path="/5D235BC5/5E3CCA16" Ref="C?"  Part="1" 
AR Path="/5E3CCA16" Ref="C?"  Part="1" 
AR Path="/5DF06544/5E3CCA16" Ref="C?"  Part="1" 
AR Path="/5E36D68B/5E3CCA16" Ref="C206"  Part="1" 
F 0 "C206" V 8171 4550 50  0000 C CNN
F 1 "100nF" V 8262 4550 50  0000 C CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 8400 4550 50  0001 C CNN
F 3 "~" H 8400 4550 50  0001 C CNN
	1    8400 4550
	0    1    1    0   
$EndComp
Wire Wire Line
	8200 4550 8200 4650
Connection ~ 8200 4550
Wire Wire Line
	8300 4550 8200 4550
Wire Wire Line
	8200 4450 8200 4550
$Comp
L 4xxx:4050 U?
U 7 1 5E3CCA0C
P 8200 5150
AR Path="/5E3CCA0C" Ref="U?"  Part="7" 
AR Path="/5E36D68B/5E3CCA0C" Ref="U203"  Part="7" 
F 0 "U203" H 8430 5196 50  0000 L CNN
F 1 "4050" H 8430 5105 50  0000 L CNN
F 2 "Package_SO:SOIC-16W_7.5x10.3mm_P1.27mm" H 8200 5150 50  0001 C CNN
F 3 "http://www.intersil.com/content/dam/intersil/documents/cd40/cd4050bms.pdf" H 8200 5150 50  0001 C CNN
	7    8200 5150
	1    0    0    -1  
$EndComp
Wire Wire Line
	9300 3000 9700 3000
$Comp
L power:GND #PWR?
U 1 1 5E3CCA8E
P 9300 3000
AR Path="/5E3CCA8E" Ref="#PWR?"  Part="1" 
AR Path="/5DF06544/5E3CCA8E" Ref="#PWR?"  Part="1" 
AR Path="/5E36D68B/5E3CCA8E" Ref="#PWR0218"  Part="1" 
F 0 "#PWR0218" H 9300 2750 50  0001 C CNN
F 1 "GND" H 9305 2827 50  0000 C CNN
F 2 "" H 9300 3000 50  0001 C CNN
F 3 "" H 9300 3000 50  0001 C CNN
	1    9300 3000
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5E3CCA88
P 7700 3000
AR Path="/5E3CCA88" Ref="#PWR?"  Part="1" 
AR Path="/5DF06544/5E3CCA88" Ref="#PWR?"  Part="1" 
AR Path="/5E36D68B/5E3CCA88" Ref="#PWR0212"  Part="1" 
F 0 "#PWR0212" H 7700 2750 50  0001 C CNN
F 1 "GND" H 7705 2827 50  0000 C CNN
F 2 "" H 7700 3000 50  0001 C CNN
F 3 "" H 7700 3000 50  0001 C CNN
	1    7700 3000
	1    0    0    -1  
$EndComp
$Comp
L power:+3V3 #PWR?
U 1 1 5E3CCA82
P 9700 2200
AR Path="/5E3CCA82" Ref="#PWR?"  Part="1" 
AR Path="/5E36D68B/5E3CCA82" Ref="#PWR0219"  Part="1" 
F 0 "#PWR0219" H 9700 2050 50  0001 C CNN
F 1 "+3V3" H 9715 2373 50  0000 C CNN
F 2 "" H 9700 2200 50  0001 C CNN
F 3 "" H 9700 2200 50  0001 C CNN
	1    9700 2200
	1    0    0    -1  
$EndComp
Wire Wire Line
	8900 3000 9300 3000
Connection ~ 9700 2300
Wire Wire Line
	9700 2300 9700 2200
Wire Wire Line
	9700 2300 9600 2300
Wire Wire Line
	9700 2600 9700 2300
Wire Wire Line
	9700 3000 9700 2900
$Comp
L Device:C C?
U 1 1 5E3CCA76
P 9700 2750
AR Path="/5E3CCA76" Ref="C?"  Part="1" 
AR Path="/5E36D68B/5E3CCA76" Ref="C208"  Part="1" 
F 0 "C208" H 9815 2796 50  0000 L CNN
F 1 "4.7uF" H 9815 2705 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 9738 2600 50  0001 C CNN
F 3 "~" H 9700 2750 50  0001 C CNN
	1    9700 2750
	1    0    0    -1  
$EndComp
Connection ~ 9300 3000
Wire Wire Line
	9300 2600 9300 3000
Wire Wire Line
	8900 2300 8900 2600
Wire Wire Line
	8900 3000 8900 2900
$Comp
L Device:C C?
U 1 1 5E3CCA6C
P 8900 2750
AR Path="/5E3CCA6C" Ref="C?"  Part="1" 
AR Path="/5E36D68B/5E3CCA6C" Ref="C207"  Part="1" 
F 0 "C207" H 9015 2796 50  0000 L CNN
F 1 "1uF" H 9015 2705 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 8938 2600 50  0001 C CNN
F 3 "~" H 8900 2750 50  0001 C CNN
	1    8900 2750
	1    0    0    -1  
$EndComp
Connection ~ 8900 2300
Wire Wire Line
	8900 2300 8900 2200
Wire Wire Line
	9000 2300 8900 2300
$Comp
L power:+5V #PWR?
U 1 1 5E3CCA63
P 8900 2200
AR Path="/5E3CCA63" Ref="#PWR?"  Part="1" 
AR Path="/5DF06544/5E3CCA63" Ref="#PWR?"  Part="1" 
AR Path="/5E36D68B/5E3CCA63" Ref="#PWR0217"  Part="1" 
F 0 "#PWR0217" H 8900 2050 50  0001 C CNN
F 1 "+5V" H 8915 2373 50  0000 C CNN
F 2 "" H 8900 2200 50  0001 C CNN
F 3 "" H 8900 2200 50  0001 C CNN
	1    8900 2200
	1    0    0    -1  
$EndComp
$Comp
L Regulator_Linear:LD1117S33TR_SOT223 U?
U 1 1 5E3CCA5D
P 9300 2300
AR Path="/5E3CCA5D" Ref="U?"  Part="1" 
AR Path="/5E36D68B/5E3CCA5D" Ref="U205"  Part="1" 
F 0 "U205" H 9300 2542 50  0000 C CNN
F 1 "LDL1117" H 9300 2451 50  0000 C CNN
F 2 "Package_TO_SOT_SMD:SOT-223-3_TabPin2" H 9300 2500 50  0001 C CNN
F 3 "http://www.st.com/st-web-ui/static/active/en/resource/technical/document/datasheet/CD00000544.pdf" H 9400 2050 50  0001 C CNN
	1    9300 2300
	1    0    0    -1  
$EndComp
$Comp
L power:+1V2 #PWR?
U 1 1 5E3CCA51
P 8200 2200
AR Path="/5E3CCA51" Ref="#PWR?"  Part="1" 
AR Path="/5E36D68B/5E3CCA51" Ref="#PWR0213"  Part="1" 
F 0 "#PWR0213" H 8200 2050 50  0001 C CNN
F 1 "+1V2" H 8215 2373 50  0000 C CNN
F 2 "" H 8200 2200 50  0001 C CNN
F 3 "" H 8200 2200 50  0001 C CNN
	1    8200 2200
	1    0    0    -1  
$EndComp
Connection ~ 7200 2500
Wire Wire Line
	7200 2600 7200 2500
Connection ~ 8200 2300
Wire Wire Line
	8200 2300 8200 2200
Wire Wire Line
	8200 2300 8100 2300
Wire Wire Line
	8200 2600 8200 2300
Connection ~ 7700 3000
Wire Wire Line
	8200 3000 8200 2900
Wire Wire Line
	7700 3000 8200 3000
Wire Wire Line
	7200 3000 7200 2900
Wire Wire Line
	7700 3000 7200 3000
Wire Wire Line
	7700 2700 7700 3000
$Comp
L Device:C C?
U 1 1 5E3CCA3F
P 8200 2750
AR Path="/5E3CCA3F" Ref="C?"  Part="1" 
AR Path="/5E36D68B/5E3CCA3F" Ref="C205"  Part="1" 
F 0 "C205" H 8315 2796 50  0000 L CNN
F 1 "1uF" H 8315 2705 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 8238 2600 50  0001 C CNN
F 3 "~" H 8200 2750 50  0001 C CNN
	1    8200 2750
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5E3CCA39
P 7200 2750
AR Path="/5E3CCA39" Ref="C?"  Part="1" 
AR Path="/5E36D68B/5E3CCA39" Ref="C204"  Part="1" 
F 0 "C204" H 7315 2796 50  0000 L CNN
F 1 "1uF" H 7315 2705 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 7238 2600 50  0001 C CNN
F 3 "~" H 7200 2750 50  0001 C CNN
	1    7200 2750
	1    0    0    -1  
$EndComp
Connection ~ 7200 2300
Wire Wire Line
	7200 2500 7300 2500
Wire Wire Line
	7200 2300 7200 2500
Wire Wire Line
	7200 2300 7200 2200
Wire Wire Line
	7300 2300 7200 2300
$Comp
L power:+5V #PWR?
U 1 1 5E3CCA2E
P 7200 2200
AR Path="/5E3CCA2E" Ref="#PWR?"  Part="1" 
AR Path="/5DF06544/5E3CCA2E" Ref="#PWR?"  Part="1" 
AR Path="/5E36D68B/5E3CCA2E" Ref="#PWR0211"  Part="1" 
F 0 "#PWR0211" H 7200 2050 50  0001 C CNN
F 1 "+5V" H 7215 2373 50  0000 C CNN
F 2 "" H 7200 2200 50  0001 C CNN
F 3 "" H 7200 2200 50  0001 C CNN
	1    7200 2200
	1    0    0    -1  
$EndComp
$Comp
L Regulator_Linear:MIC5504-1.2YM5 U?
U 1 1 5E3CCA28
P 7700 2400
AR Path="/5E3CCA28" Ref="U?"  Part="1" 
AR Path="/5E36D68B/5E3CCA28" Ref="U204"  Part="1" 
F 0 "U204" H 7700 2767 50  0000 C CNN
F 1 "MIC5504-1.2YM5" H 7700 2676 50  0000 C CNN
F 2 "Package_TO_SOT_SMD:SOT-23-5" H 7700 2000 50  0001 C CNN
F 3 "http://ww1.microchip.com/downloads/en/DeviceDoc/MIC550X.pdf" H 7450 2650 50  0001 C CNN
	1    7700 2400
	1    0    0    -1  
$EndComp
Text HLabel 4400 3200 0    50   Input ~ 0
~D_EN
Text HLabel 5600 5850 2    50   Output ~ 0
~LV_RD
Text HLabel 5600 5500 2    50   Output ~ 0
~LV_WR
Text HLabel 6000 3800 2    50   Output ~ 0
LV_A[0..3]
Wire Bus Line
	5700 3800 6000 3800
Text HLabel 6100 1750 2    50   BiDi ~ 0
LV_D[0..7]
Wire Wire Line
	4200 3100 4400 3100
Entry Wire Line
	4100 3000 4200 3100
Entry Wire Line
	5600 4450 5700 4350
Entry Wire Line
	5600 4100 5700 4000
Entry Wire Line
	5600 4800 5700 4700
Entry Wire Line
	5600 5150 5700 5050
Wire Wire Line
	5600 5850 5200 5850
Wire Wire Line
	5600 4800 5200 4800
Wire Wire Line
	5600 4100 5200 4100
Wire Wire Line
	5600 4450 5200 4450
Wire Wire Line
	5600 5150 5200 5150
Wire Wire Line
	5600 5500 5200 5500
Text Label 5200 5150 0    50   ~ 0
LV_A3
Text Label 5200 4100 0    50   ~ 0
LV_A0
Text Label 5200 4450 0    50   ~ 0
LV_A1
Text Label 5200 4800 0    50   ~ 0
LV_A2
$Comp
L power:+3V3 #PWR?
U 1 1 5E3A01BF
P 5100 1500
AR Path="/5E3A01BF" Ref="#PWR?"  Part="1" 
AR Path="/5E36D68B/5E3A01BF" Ref="#PWR0209"  Part="1" 
F 0 "#PWR0209" H 5100 1350 50  0001 C CNN
F 1 "+3V3" H 5115 1673 50  0000 C CNN
F 2 "" H 5100 1500 50  0001 C CNN
F 3 "" H 5100 1500 50  0001 C CNN
	1    5100 1500
	1    0    0    -1  
$EndComp
Text Label 4400 3100 2    50   ~ 0
~RD
Wire Wire Line
	4200 5850 4600 5850
Wire Wire Line
	4200 4800 4600 4800
Wire Wire Line
	4200 4100 4600 4100
Wire Wire Line
	4200 4450 4600 4450
Wire Wire Line
	4200 5150 4600 5150
Wire Wire Line
	4200 5500 4600 5500
Text Label 4600 5150 2    50   ~ 0
A3
Text Label 4600 4100 2    50   ~ 0
A0
Text Label 4600 5500 2    50   ~ 0
~WR
Text Label 4600 4450 2    50   ~ 0
A1
Text Label 4600 4800 2    50   ~ 0
A2
Text Label 4600 5850 2    50   ~ 0
~RD
Entry Wire Line
	4100 4350 4200 4450
Entry Wire Line
	4100 5400 4200 5500
Entry Wire Line
	4100 5050 4200 5150
Entry Wire Line
	4100 4000 4200 4100
Entry Wire Line
	4100 5750 4200 5850
Entry Wire Line
	4100 4700 4200 4800
$Comp
L 4xxx:4050 U?
U 6 1 5E3A0173
P 4900 5850
AR Path="/5E3A0173" Ref="U?"  Part="6" 
AR Path="/5E36D68B/5E3A0173" Ref="U203"  Part="6" 
F 0 "U203" H 5050 6000 50  0000 C CNN
F 1 "4050" H 4850 5850 50  0000 C CNN
F 2 "Package_SO:SOIC-16W_7.5x10.3mm_P1.27mm" H 4900 5850 50  0001 C CNN
F 3 "http://www.intersil.com/content/dam/intersil/documents/cd40/cd4050bms.pdf" H 4900 5850 50  0001 C CNN
	6    4900 5850
	1    0    0    -1  
$EndComp
$Comp
L 4xxx:4050 U?
U 5 1 5E3A016D
P 4900 5150
AR Path="/5E3A016D" Ref="U?"  Part="5" 
AR Path="/5E36D68B/5E3A016D" Ref="U203"  Part="5" 
F 0 "U203" H 5050 5300 50  0000 C CNN
F 1 "4050" H 4850 5150 50  0000 C CNN
F 2 "Package_SO:SOIC-16W_7.5x10.3mm_P1.27mm" H 4900 5150 50  0001 C CNN
F 3 "http://www.intersil.com/content/dam/intersil/documents/cd40/cd4050bms.pdf" H 4900 5150 50  0001 C CNN
	5    4900 5150
	1    0    0    -1  
$EndComp
$Comp
L 4xxx:4050 U?
U 4 1 5E3A0167
P 4900 4450
AR Path="/5E3A0167" Ref="U?"  Part="4" 
AR Path="/5E36D68B/5E3A0167" Ref="U203"  Part="4" 
F 0 "U203" H 5050 4600 50  0000 C CNN
F 1 "4050" H 4850 4450 50  0000 C CNN
F 2 "Package_SO:SOIC-16W_7.5x10.3mm_P1.27mm" H 4900 4450 50  0001 C CNN
F 3 "http://www.intersil.com/content/dam/intersil/documents/cd40/cd4050bms.pdf" H 4900 4450 50  0001 C CNN
	4    4900 4450
	1    0    0    -1  
$EndComp
$Comp
L 4xxx:4050 U?
U 3 1 5E3A0161
P 4900 4100
AR Path="/5E3A0161" Ref="U?"  Part="3" 
AR Path="/5E36D68B/5E3A0161" Ref="U203"  Part="3" 
F 0 "U203" H 5050 4250 50  0000 C CNN
F 1 "4050" H 4850 4100 50  0000 C CNN
F 2 "Package_SO:SOIC-16W_7.5x10.3mm_P1.27mm" H 4900 4100 50  0001 C CNN
F 3 "http://www.intersil.com/content/dam/intersil/documents/cd40/cd4050bms.pdf" H 4900 4100 50  0001 C CNN
	3    4900 4100
	1    0    0    -1  
$EndComp
$Comp
L 4xxx:4050 U?
U 2 1 5E3A015B
P 4900 4800
AR Path="/5E3A015B" Ref="U?"  Part="2" 
AR Path="/5E36D68B/5E3A015B" Ref="U203"  Part="2" 
F 0 "U203" H 5050 4950 50  0000 C CNN
F 1 "4050" H 4850 4800 50  0000 C CNN
F 2 "Package_SO:SOIC-16W_7.5x10.3mm_P1.27mm" H 4900 4800 50  0001 C CNN
F 3 "http://www.intersil.com/content/dam/intersil/documents/cd40/cd4050bms.pdf" H 4900 4800 50  0001 C CNN
	2    4900 4800
	1    0    0    -1  
$EndComp
$Comp
L 4xxx:4050 U?
U 1 1 5E3A0155
P 4900 5500
AR Path="/5E3A0155" Ref="U?"  Part="1" 
AR Path="/5E36D68B/5E3A0155" Ref="U203"  Part="1" 
F 0 "U203" H 5050 5650 50  0000 C CNN
F 1 "4050" H 4850 5500 50  0000 C CNN
F 2 "Package_SO:SOIC-16W_7.5x10.3mm_P1.27mm" H 4900 5500 50  0001 C CNN
F 3 "http://www.intersil.com/content/dam/intersil/documents/cd40/cd4050bms.pdf" H 4900 5500 50  0001 C CNN
	1    4900 5500
	1    0    0    -1  
$EndComp
Wire Bus Line
	5800 1750 6100 1750
Text Label 5400 2350 0    50   ~ 0
LV_D6
Text Label 5400 2250 0    50   ~ 0
LV_D7
Text Label 5400 2550 0    50   ~ 0
LV_D4
Text Label 5400 2450 0    50   ~ 0
LV_D5
Text Label 5400 2750 0    50   ~ 0
LV_D2
Text Label 5400 2650 0    50   ~ 0
LV_D3
Text Label 5400 2950 0    50   ~ 0
LV_D0
Text Label 5400 2850 0    50   ~ 0
LV_D1
Entry Wire Line
	5700 2450 5800 2350
Entry Wire Line
	5700 2550 5800 2450
Entry Wire Line
	5700 2650 5800 2550
Entry Wire Line
	5700 2750 5800 2650
Entry Wire Line
	5700 2850 5800 2750
Entry Wire Line
	5700 2950 5800 2850
Entry Wire Line
	5700 2350 5800 2250
Entry Wire Line
	5700 2250 5800 2150
Text Label 4400 2350 2    50   ~ 0
D6
Text Label 4400 2250 2    50   ~ 0
D7
Text Label 4400 2550 2    50   ~ 0
D4
Text Label 4400 2450 2    50   ~ 0
D5
Text Label 4400 2750 2    50   ~ 0
D2
Text Label 4400 2650 2    50   ~ 0
D3
Text Label 4400 2950 2    50   ~ 0
D0
Text Label 4400 2850 2    50   ~ 0
D1
Wire Wire Line
	4200 2950 4400 2950
Wire Wire Line
	4200 2850 4400 2850
Wire Wire Line
	4200 2750 4400 2750
Wire Wire Line
	4200 2650 4400 2650
Wire Wire Line
	4200 2550 4400 2550
Wire Wire Line
	4200 2450 4400 2450
Wire Wire Line
	4200 2350 4400 2350
Wire Wire Line
	4200 2250 4400 2250
Entry Wire Line
	4200 2450 4100 2350
Entry Wire Line
	4200 2550 4100 2450
Entry Wire Line
	4200 2650 4100 2550
Entry Wire Line
	4200 2750 4100 2650
Entry Wire Line
	4200 2850 4100 2750
Entry Wire Line
	4200 2950 4100 2850
Entry Wire Line
	4200 2350 4100 2250
Entry Wire Line
	4200 2250 4100 2150
$Comp
L power:GND #PWR?
U 1 1 5E3A011D
P 5400 1600
AR Path="/5CE42ADD/5E3A011D" Ref="#PWR?"  Part="1" 
AR Path="/5CE42ADD/5CED3C7F/5E3A011D" Ref="#PWR?"  Part="1" 
AR Path="/5D235BC5/5E3A011D" Ref="#PWR?"  Part="1" 
AR Path="/5E3A011D" Ref="#PWR?"  Part="1" 
AR Path="/5DF06544/5E3A011D" Ref="#PWR?"  Part="1" 
AR Path="/5E36D68B/5E3A011D" Ref="#PWR0210"  Part="1" 
F 0 "#PWR0210" H 5400 1350 50  0001 C CNN
F 1 "GND" V 5405 1472 50  0000 R CNN
F 2 "" H 5400 1600 50  0001 C CNN
F 3 "" H 5400 1600 50  0001 C CNN
	1    5400 1600
	0    -1   -1   0   
$EndComp
$Comp
L Device:C_Small C?
U 1 1 5E3A0117
P 5300 1600
AR Path="/5CE42ADD/5E3A0117" Ref="C?"  Part="1" 
AR Path="/5CE42ADD/5CED3C7F/5E3A0117" Ref="C?"  Part="1" 
AR Path="/5D235BC5/5E3A0117" Ref="C?"  Part="1" 
AR Path="/5E3A0117" Ref="C?"  Part="1" 
AR Path="/5DF06544/5E3A0117" Ref="C?"  Part="1" 
AR Path="/5E36D68B/5E3A0117" Ref="C203"  Part="1" 
F 0 "C203" V 5071 1600 50  0000 C CNN
F 1 "100nF" V 5162 1600 50  0000 C CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 5300 1600 50  0001 C CNN
F 3 "~" H 5300 1600 50  0001 C CNN
	1    5300 1600
	0    1    1    0   
$EndComp
Wire Wire Line
	5000 1700 5000 1600
Wire Wire Line
	5100 1600 5000 1600
Wire Wire Line
	5100 1600 5100 1700
Connection ~ 5100 1600
Wire Wire Line
	5200 1600 5100 1600
Wire Wire Line
	5100 1500 5100 1600
Wire Wire Line
	4900 3400 5050 3400
Connection ~ 4900 3400
Wire Wire Line
	4750 3400 4900 3400
$Comp
L power:GND #PWR?
U 1 1 5E3A0108
P 4900 3400
AR Path="/5E3A0108" Ref="#PWR?"  Part="1" 
AR Path="/5DF06544/5E3A0108" Ref="#PWR?"  Part="1" 
AR Path="/5E36D68B/5E3A0108" Ref="#PWR0208"  Part="1" 
F 0 "#PWR0208" H 4900 3150 50  0001 C CNN
F 1 "GND" H 4905 3227 50  0000 C CNN
F 2 "" H 4900 3400 50  0001 C CNN
F 3 "" H 4900 3400 50  0001 C CNN
	1    4900 3400
	1    0    0    -1  
$EndComp
$Comp
L zi28:74LVC4245 U?
U 1 1 5E3A0102
P 4900 2400
AR Path="/5E3A0102" Ref="U?"  Part="1" 
AR Path="/5E36D68B/5E3A0102" Ref="U202"  Part="1" 
F 0 "U202" H 5250 3050 50  0000 C CNN
F 1 "74LVC4245" V 4900 2200 50  0000 C CNN
F 2 "Package_SO:SOIC-24W_7.5x15.4mm_P1.27mm" H 4900 2400 50  0001 C CNN
F 3 "" H 4900 2400 50  0001 C CNN
	1    4900 2400
	1    0    0    -1  
$EndComp
Wire Wire Line
	4700 1500 4700 1600
$Comp
L Device:C_Small C?
U 1 1 5E3A00E0
P 4500 1600
AR Path="/5CE42ADD/5E3A00E0" Ref="C?"  Part="1" 
AR Path="/5CE42ADD/5CED3C7F/5E3A00E0" Ref="C?"  Part="1" 
AR Path="/5D235BC5/5E3A00E0" Ref="C?"  Part="1" 
AR Path="/5E3A00E0" Ref="C?"  Part="1" 
AR Path="/5DF06544/5E3A00E0" Ref="C?"  Part="1" 
AR Path="/5E36D68B/5E3A00E0" Ref="C202"  Part="1" 
F 0 "C202" V 4271 1600 50  0000 C CNN
F 1 "100nF" V 4362 1600 50  0000 C CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 4500 1600 50  0001 C CNN
F 3 "~" H 4500 1600 50  0001 C CNN
	1    4500 1600
	0    -1   1    0   
$EndComp
$Comp
L power:+5V #PWR?
U 1 1 5E3A00DA
P 4700 1500
AR Path="/5CE42ADD/5E3A00DA" Ref="#PWR?"  Part="1" 
AR Path="/5CE42ADD/5CED3C7F/5E3A00DA" Ref="#PWR?"  Part="1" 
AR Path="/5D235BC5/5E3A00DA" Ref="#PWR?"  Part="1" 
AR Path="/5E3A00DA" Ref="#PWR?"  Part="1" 
AR Path="/5DF06544/5E3A00DA" Ref="#PWR?"  Part="1" 
AR Path="/5E36D68B/5E3A00DA" Ref="#PWR0207"  Part="1" 
F 0 "#PWR0207" H 4700 1350 50  0001 C CNN
F 1 "+5V" H 4715 1673 50  0000 C CNN
F 2 "" H 4700 1500 50  0001 C CNN
F 3 "" H 4700 1500 50  0001 C CNN
	1    4700 1500
	-1   0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5E3A00D4
P 4400 1600
AR Path="/5CE42ADD/5E3A00D4" Ref="#PWR?"  Part="1" 
AR Path="/5CE42ADD/5CED3C7F/5E3A00D4" Ref="#PWR?"  Part="1" 
AR Path="/5D235BC5/5E3A00D4" Ref="#PWR?"  Part="1" 
AR Path="/5E3A00D4" Ref="#PWR?"  Part="1" 
AR Path="/5DF06544/5E3A00D4" Ref="#PWR?"  Part="1" 
AR Path="/5E36D68B/5E3A00D4" Ref="#PWR0206"  Part="1" 
F 0 "#PWR0206" H 4400 1350 50  0001 C CNN
F 1 "GND" V 4405 1472 50  0000 R CNN
F 2 "" H 4400 1600 50  0001 C CNN
F 3 "" H 4400 1600 50  0001 C CNN
	1    4400 1600
	0    1    -1   0   
$EndComp
Wire Wire Line
	4700 1600 4600 1600
Wire Wire Line
	4700 1600 4700 1700
Connection ~ 4700 1600
$Comp
L Connector:Conn_01x24_Male J?
U 1 1 5E3A009A
P 1450 2950
AR Path="/5E3A009A" Ref="J?"  Part="1" 
AR Path="/5DF06544/5E3A009A" Ref="J?"  Part="1" 
AR Path="/5E36D68B/5E3A009A" Ref="J201"  Part="1" 
F 0 "J201" H 1558 4231 50  0000 C CNN
F 1 "Conn_02x12_Male" H 1558 4140 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_2x12_P2.54mm_Horizontal" H 1450 2950 50  0001 C CNN
F 3 "~" H 1450 2950 50  0001 C CNN
	1    1450 2950
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR?
U 1 1 5E3A00A0
P 2050 1950
AR Path="/5E3A00A0" Ref="#PWR?"  Part="1" 
AR Path="/5DF06544/5E3A00A0" Ref="#PWR?"  Part="1" 
AR Path="/5E36D68B/5E3A00A0" Ref="#PWR0201"  Part="1" 
F 0 "#PWR0201" H 2050 1800 50  0001 C CNN
F 1 "+5V" H 2065 2123 50  0000 C CNN
F 2 "" H 2050 1950 50  0001 C CNN
F 3 "" H 2050 1950 50  0001 C CNN
	1    2050 1950
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5E3A00A6
P 2050 2050
AR Path="/5E3A00A6" Ref="#PWR?"  Part="1" 
AR Path="/5DF06544/5E3A00A6" Ref="#PWR?"  Part="1" 
AR Path="/5E36D68B/5E3A00A6" Ref="#PWR0202"  Part="1" 
F 0 "#PWR0202" H 2050 1800 50  0001 C CNN
F 1 "GND" H 2150 2050 50  0000 C CNN
F 2 "" H 2050 2050 50  0001 C CNN
F 3 "" H 2050 2050 50  0001 C CNN
	1    2050 2050
	1    0    0    -1  
$EndComp
NoConn ~ 1650 4050
Text Label 1650 2250 0    50   ~ 0
D1
Text Label 1650 2350 0    50   ~ 0
D0
Text Label 1650 2450 0    50   ~ 0
D3
Text Label 1650 2550 0    50   ~ 0
D2
Text Label 1650 2650 0    50   ~ 0
D5
Text Label 1650 2750 0    50   ~ 0
D4
Text Label 1650 2850 0    50   ~ 0
D7
Text Label 1650 2950 0    50   ~ 0
D6
Wire Wire Line
	1650 1850 1650 1950
Connection ~ 1650 1950
Wire Wire Line
	1650 2150 1650 2050
Connection ~ 1650 2050
Wire Wire Line
	1950 3750 1650 3750
Wire Wire Line
	1650 2950 2350 2950
Wire Wire Line
	1650 2850 2350 2850
Wire Wire Line
	1650 2750 2350 2750
Wire Wire Line
	1650 2650 2350 2650
Wire Wire Line
	1650 2550 2350 2550
Wire Wire Line
	1650 2450 2350 2450
Wire Wire Line
	1650 2350 2350 2350
NoConn ~ 1650 3450
Text Notes 1700 3500 0    50   ~ 0
~WAIT
Text Notes 1700 4100 0    50   ~ 0
NC
Wire Wire Line
	1650 2050 1850 2050
Connection ~ 1850 2050
Wire Wire Line
	1850 2050 2050 2050
$Comp
L power:PWR_FLAG #FLG?
U 1 1 5E3A00F3
P 1850 2050
AR Path="/5E3A00F3" Ref="#FLG?"  Part="1" 
AR Path="/5DF06544/5E3A00F3" Ref="#FLG?"  Part="1" 
AR Path="/5E36D68B/5E3A00F3" Ref="#FLG0202"  Part="1" 
F 0 "#FLG0202" H 1850 2125 50  0001 C CNN
F 1 "PWR_FLAG" H 1850 2223 50  0001 C CNN
F 2 "" H 1850 2050 50  0001 C CNN
F 3 "~" H 1850 2050 50  0001 C CNN
	1    1850 2050
	-1   0    0    1   
$EndComp
Wire Wire Line
	1850 1950 2050 1950
Wire Wire Line
	1650 1950 1850 1950
Connection ~ 1850 1950
$Comp
L power:PWR_FLAG #FLG?
U 1 1 5E3A00FC
P 1850 1950
AR Path="/5E3A00FC" Ref="#FLG?"  Part="1" 
AR Path="/5DF06544/5E3A00FC" Ref="#FLG?"  Part="1" 
AR Path="/5E36D68B/5E3A00FC" Ref="#FLG0201"  Part="1" 
F 0 "#FLG0201" H 1850 2025 50  0001 C CNN
F 1 "PWR_FLAG" H 1850 2123 50  0001 C CNN
F 2 "" H 1850 1950 50  0001 C CNN
F 3 "~" H 1850 1950 50  0001 C CNN
	1    1850 1950
	1    0    0    -1  
$EndComp
Text Label 1650 3050 0    50   ~ 0
A1
Text Label 1650 3150 0    50   ~ 0
A0
Text Label 1650 3350 0    50   ~ 0
A2
Wire Wire Line
	1650 3050 2350 3050
Wire Wire Line
	1650 3350 2350 3350
Wire Wire Line
	1650 3250 2350 3250
Wire Wire Line
	1650 3150 2350 3150
Text Label 1650 3250 0    50   ~ 0
A3
Text Label 1650 3850 0    50   ~ 0
~WR
Text Label 1650 3950 0    50   ~ 0
~RD
Wire Wire Line
	1650 3950 2350 3950
Wire Wire Line
	1650 3850 2350 3850
Text Notes 1700 3700 0    50   ~ 0
~IORQ
NoConn ~ 1650 3650
Wire Wire Line
	1950 3550 1650 3550
Wire Wire Line
	1650 2250 2350 2250
Entry Wire Line
	2350 2250 2450 2150
Entry Wire Line
	2350 2350 2450 2250
Entry Wire Line
	2350 2950 2450 2850
Entry Wire Line
	2350 2850 2450 2750
Entry Wire Line
	2350 2750 2450 2650
Entry Wire Line
	2350 2650 2450 2550
Entry Wire Line
	2350 2550 2450 2450
Entry Wire Line
	2350 2450 2450 2350
Entry Wire Line
	2450 2950 2350 3050
Entry Wire Line
	2450 3050 2350 3150
Entry Wire Line
	2450 3850 2350 3950
Entry Wire Line
	2450 3750 2350 3850
Entry Wire Line
	2450 3250 2350 3350
Entry Wire Line
	2450 3150 2350 3250
$Comp
L zi28:11AA020 U?
U 1 1 5E3A00CB
P 2400 4950
AR Path="/5E3A00CB" Ref="U?"  Part="1" 
AR Path="/5DF06544/5E3A00CB" Ref="U?"  Part="1" 
AR Path="/5E36D68B/5E3A00CB" Ref="U201"  Part="1" 
F 0 "U201" H 2678 4996 50  0000 L CNN
F 1 "11AA020" H 2678 4905 50  0000 L CNN
F 2 "Package_TO_SOT_THT:TO-92" H 2400 4950 50  0001 C CNN
F 3 "" H 2400 4950 50  0001 C CNN
	1    2400 4950
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5E3A00EA
P 2400 5300
AR Path="/5E3A00EA" Ref="#PWR?"  Part="1" 
AR Path="/5DF06544/5E3A00EA" Ref="#PWR?"  Part="1" 
AR Path="/5E36D68B/5E3A00EA" Ref="#PWR0204"  Part="1" 
F 0 "#PWR0204" H 2400 5050 50  0001 C CNN
F 1 "GND" H 2405 5127 50  0000 C CNN
F 2 "" H 2400 5300 50  0001 C CNN
F 3 "" H 2400 5300 50  0001 C CNN
	1    2400 5300
	1    0    0    -1  
$EndComp
Connection ~ 2400 4500
Wire Wire Line
	2400 4500 2400 4600
Wire Wire Line
	2400 4500 2500 4500
$Comp
L power:GND #PWR?
U 1 1 5E3A017C
P 2700 4500
AR Path="/5CE42ADD/5E3A017C" Ref="#PWR?"  Part="1" 
AR Path="/5CE42ADD/5CED3C7F/5E3A017C" Ref="#PWR?"  Part="1" 
AR Path="/5D235BC5/5E3A017C" Ref="#PWR?"  Part="1" 
AR Path="/5E3A017C" Ref="#PWR?"  Part="1" 
AR Path="/5DF06544/5E3A017C" Ref="#PWR?"  Part="1" 
AR Path="/5E36D68B/5E3A017C" Ref="#PWR0205"  Part="1" 
F 0 "#PWR0205" H 2700 4250 50  0001 C CNN
F 1 "GND" V 2705 4372 50  0000 R CNN
F 2 "" H 2700 4500 50  0001 C CNN
F 3 "" H 2700 4500 50  0001 C CNN
	1    2700 4500
	0    -1   -1   0   
$EndComp
$Comp
L power:+5V #PWR?
U 1 1 5E3A0182
P 2400 4400
AR Path="/5CE42ADD/5E3A0182" Ref="#PWR?"  Part="1" 
AR Path="/5CE42ADD/5CED3C7F/5E3A0182" Ref="#PWR?"  Part="1" 
AR Path="/5D235BC5/5E3A0182" Ref="#PWR?"  Part="1" 
AR Path="/5E3A0182" Ref="#PWR?"  Part="1" 
AR Path="/5DF06544/5E3A0182" Ref="#PWR?"  Part="1" 
AR Path="/5E36D68B/5E3A0182" Ref="#PWR0203"  Part="1" 
F 0 "#PWR0203" H 2400 4250 50  0001 C CNN
F 1 "+5V" H 2415 4573 50  0000 C CNN
F 2 "" H 2400 4400 50  0001 C CNN
F 3 "" H 2400 4400 50  0001 C CNN
	1    2400 4400
	1    0    0    -1  
$EndComp
$Comp
L Device:C_Small C?
U 1 1 5E3A0188
P 2600 4500
AR Path="/5CE42ADD/5E3A0188" Ref="C?"  Part="1" 
AR Path="/5CE42ADD/5CED3C7F/5E3A0188" Ref="C?"  Part="1" 
AR Path="/5D235BC5/5E3A0188" Ref="C?"  Part="1" 
AR Path="/5E3A0188" Ref="C?"  Part="1" 
AR Path="/5DF06544/5E3A0188" Ref="C?"  Part="1" 
AR Path="/5E36D68B/5E3A0188" Ref="C201"  Part="1" 
F 0 "C201" V 2371 4500 50  0000 C CNN
F 1 "100nF" V 2462 4500 50  0000 C CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 2600 4500 50  0001 C CNN
F 3 "~" H 2600 4500 50  0001 C CNN
	1    2600 4500
	0    1    1    0   
$EndComp
Wire Wire Line
	2400 4400 2400 4500
Wire Wire Line
	2050 4950 1950 4950
Wire Wire Line
	1950 4950 1950 4150
Wire Wire Line
	1650 4150 1950 4150
Text HLabel 1950 3550 2    50   BiDi ~ 0
~RST
Text HLabel 1950 3750 2    50   Input ~ 0
~INT
Wire Bus Line
	2450 2950 4100 2950
Wire Bus Line
	2450 2050 4100 2050
Wire Wire Line
	5400 2250 5700 2250
Wire Wire Line
	5400 2350 5700 2350
Wire Wire Line
	5400 2450 5700 2450
Wire Wire Line
	5400 2550 5700 2550
Wire Wire Line
	5400 2650 5700 2650
Wire Wire Line
	5400 2750 5700 2750
Wire Wire Line
	5400 2850 5700 2850
Wire Wire Line
	5400 2950 5700 2950
Wire Bus Line
	5700 3800 5700 5050
Wire Bus Line
	4100 2950 4100 5750
Wire Bus Line
	5800 1750 5800 2850
Wire Bus Line
	4100 2050 4100 2850
Wire Bus Line
	2450 2950 2450 3850
Wire Bus Line
	2450 2050 2450 2850
$EndSCHEMATC
