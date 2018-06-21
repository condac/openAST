EESchema Schematic File Version 2
LIBS:power
LIBS:device
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:special
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:motorola
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:valves
LIBS:amb_blackbox-cache
EELAYER 27 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title ""
Date "14 may 2018"
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L CONN_2 Connector
U 1 1 55487760
P 6700 3650
F 0 "Connector" V 6650 3650 40  0000 C CNN
F 1 "CONN_2" V 6750 3650 40  0000 C CNN
F 2 "~" H 6700 3650 60  0000 C CNN
F 3 "~" H 6700 3650 60  0000 C CNN
	1    6700 3650
	1    0    0    -1  
$EndComp
$Comp
L CONN_2 P1
U 1 1 5548776F
P 2000 3750
F 0 "P1" V 1950 3750 40  0000 C CNN
F 1 "CONN_2" V 2050 3750 40  0000 C CNN
F 2 "~" H 2000 3750 60  0000 C CNN
F 3 "~" H 2000 3750 60  0000 C CNN
	1    2000 3750
	-1   0    0    1   
$EndComp
$Comp
L GND #PWR1
U 1 1 554877BB
P 2550 4100
F 0 "#PWR1" H 2550 4100 30  0001 C CNN
F 1 "GND" H 2550 4030 30  0001 C CNN
F 2 "" H 2550 4100 60  0000 C CNN
F 3 "" H 2550 4100 60  0000 C CNN
	1    2550 4100
	1    0    0    -1  
$EndComp
Wire Wire Line
	2350 3850 2550 3850
Wire Wire Line
	2550 3850 2750 3850
Wire Wire Line
	2550 3850 2550 4100
Wire Wire Line
	2350 3650 3000 3650
$Comp
L R R1
U 1 1 55487821
P 3000 4050
F 0 "R1" V 3080 4050 40  0000 C CNN
F 1 "100k" V 3007 4051 40  0000 C CNN
F 2 "~" V 2930 4050 30  0000 C CNN
F 3 "~" H 3000 4050 30  0000 C CNN
	1    3000 4050
	1    0    0    -1  
$EndComp
Wire Wire Line
	3000 3500 3000 3650
Wire Wire Line
	3000 3650 3000 3800
$Comp
L C C1
U 1 1 5548784F
P 3000 3300
F 0 "C1" H 3000 3400 40  0000 L CNN
F 1 "10nF" H 3006 3215 40  0000 L CNN
F 2 "~" H 3038 3150 30  0000 C CNN
F 3 "~" H 3000 3300 60  0000 C CNN
	1    3000 3300
	1    0    0    -1  
$EndComp
$Comp
L TRANSFO-AUDIO FT-50A-J
U 1 1 55487B5E
P 4200 3650
F 0 "FT-50A-J" H 4200 4110 70  0000 C CNN
F 1 "5:9" H 4210 4020 70  0000 C CNN
F 2 "~" H 4200 3650 60  0000 C CNN
F 3 "~" H 4200 3650 60  0000 C CNN
	1    4200 3650
	1    0    0    -1  
$EndComp
Text Label 4500 3650 0    60   ~ 0
9 Turns on antenna side
Text Label 3700 3650 0    60   ~ 0
5 Turns
Connection ~ 3000 3650
Wire Wire Line
	3000 3100 3800 3100
Wire Wire Line
	3800 3100 3800 3450
Wire Wire Line
	3800 4300 3800 3850
Wire Wire Line
	2750 4300 3000 4300
Wire Wire Line
	3000 4300 3800 4300
Wire Wire Line
	2750 3850 2750 4300
Connection ~ 2550 3850
Connection ~ 3000 4300
$Comp
L C C2
U 1 1 55487E20
P 5200 3400
F 0 "C2" H 5200 3500 40  0000 L CNN
F 1 "1nF" H 5206 3315 40  0000 L CNN
F 2 "~" H 5238 3250 30  0000 C CNN
F 3 "~" H 5200 3400 60  0000 C CNN
	1    5200 3400
	0    -1   -1   0   
$EndComp
$Comp
L C C3
U 1 1 55487E34
P 5200 3900
F 0 "C3" H 5200 4000 40  0000 L CNN
F 1 "1nF" H 5206 3815 40  0000 L CNN
F 2 "~" H 5238 3750 30  0000 C CNN
F 3 "~" H 5200 3900 60  0000 C CNN
	1    5200 3900
	0    -1   -1   0   
$EndComp
Wire Wire Line
	5400 3900 5900 3900
Wire Wire Line
	5900 3900 6350 3900
Wire Wire Line
	6350 3900 6350 3750
Wire Wire Line
	5000 3900 4600 3900
Wire Wire Line
	4600 3900 4600 3850
Wire Wire Line
	5000 3400 4600 3400
Wire Wire Line
	4600 3400 4600 3450
$Comp
L R R3
U 1 1 55488138
P 8850 3650
F 0 "R3" V 8930 3650 40  0000 C CNN
F 1 "470" V 8857 3651 40  0000 C CNN
F 2 "~" V 8780 3650 30  0000 C CNN
F 3 "~" H 8850 3650 30  0000 C CNN
	1    8850 3650
	1    0    0    -1  
$EndComp
Wire Wire Line
	8850 3400 6950 3400
Wire Wire Line
	6950 3400 6950 3550
Wire Wire Line
	6950 3550 6800 3550
Wire Wire Line
	8850 3900 6950 3900
Wire Wire Line
	6950 3900 6950 3750
Wire Wire Line
	6950 3750 6800 3750
Text Notes 7700 3350 0    60   ~ 0
Max 10m
Wire Notes Line
	7100 4600 7100 2600
Wire Notes Line
	8700 4600 8700 2600
Text Notes 7600 4000 0    60   ~ 0
Antenna on track
Text Notes 7250 3750 1    60   ~ 0
45cm
Text Notes 1200 3550 0    60   ~ 0
Coax connector
Wire Wire Line
	6350 3400 6350 3550
Wire Wire Line
	5400 3400 5900 3400
Wire Wire Line
	5900 3400 6350 3400
$EndSCHEMATC
