EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
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
L Device:R_US R1
U 1 1 5ED76E27
P 2750 2600
F 0 "R1" H 2818 2646 50  0000 L CNN
F 1 "47k" H 2818 2555 50  0000 L CNN
F 2 "" V 2790 2590 50  0001 C CNN
F 3 "~" H 2750 2600 50  0001 C CNN
	1    2750 2600
	1    0    0    -1  
$EndComp
$Comp
L Amplifier_Operational:LM358 U1
U 1 1 5ED7A07A
P 3700 2700
F 0 "U1" H 3700 3067 50  0000 C CNN
F 1 "LM358" H 3700 2976 50  0000 C CNN
F 2 "" H 3700 2700 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/lm2904-n.pdf" H 3700 2700 50  0001 C CNN
	1    3700 2700
	1    0    0    -1  
$EndComp
$Comp
L Amplifier_Operational:LM358 U1
U 3 1 5ED7E0CD
P 3700 2700
F 0 "U1" H 3658 2746 50  0000 L CNN
F 1 "LM358" H 3658 2655 50  0000 L CNN
F 2 "" H 3700 2700 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/lm2904-n.pdf" H 3700 2700 50  0001 C CNN
	3    3700 2700
	1    0    0    -1  
$EndComp
Text GLabel 3000 1650 0    50   Input ~ 0
AmbientSensor_Out
Wire Wire Line
	2750 2750 2750 2800
Wire Wire Line
	3400 2800 2750 2800
Connection ~ 2750 2800
Wire Wire Line
	2750 2800 2750 2850
Wire Wire Line
	3400 2600 3200 2600
Wire Wire Line
	2750 3150 2750 3200
Text GLabel 4450 2700 2    50   Output ~ 0
Arduino_8
Wire Wire Line
	4000 2700 4450 2700
Wire Wire Line
	3600 2400 2750 2400
Connection ~ 2750 2400
Wire Wire Line
	2750 2400 2750 2450
Wire Wire Line
	3600 3000 3600 3200
Wire Wire Line
	3600 3200 2750 3200
Connection ~ 2750 3200
Text Label 3050 2800 0    50   ~ 0
0.35V
$Comp
L Device:D D1
U 1 1 5EE22CB3
P 2750 3000
F 0 "D1" V 2796 2921 50  0000 R CNN
F 1 "1N4148" V 2705 2921 50  0000 R CNN
F 2 "" H 2750 3000 50  0001 C CNN
F 3 "~" H 2750 3000 50  0001 C CNN
	1    2750 3000
	0    -1   -1   0   
$EndComp
$Comp
L Device:R_US R2
U 1 1 605C4E0F
P 2450 2600
F 0 "R2" H 2518 2646 50  0000 L CNN
F 1 "47k" H 2518 2555 50  0000 L CNN
F 2 "" V 2490 2590 50  0001 C CNN
F 3 "~" H 2450 2600 50  0001 C CNN
	1    2450 2600
	1    0    0    -1  
$EndComp
Wire Wire Line
	2750 2800 2450 2800
Wire Wire Line
	2450 2800 2450 2750
Wire Wire Line
	2450 2450 2450 2400
Wire Wire Line
	2450 2400 2750 2400
$Comp
L Switch:SW_Push SW1
U 1 1 605C68E3
P 4100 3200
F 0 "SW1" H 4100 3485 50  0000 C CNN
F 1 "SW_Mouse" H 4100 3394 50  0000 C CNN
F 2 "" H 4100 3400 50  0001 C CNN
F 3 "~" H 4100 3400 50  0001 C CNN
	1    4100 3200
	1    0    0    -1  
$EndComp
Wire Wire Line
	3900 3200 3600 3200
Connection ~ 3600 3200
Text GLabel 4450 3200 2    50   Output ~ 0
Arduino_9
Wire Wire Line
	4300 3200 4450 3200
Text GLabel 4450 1900 2    50   Output ~ 0
Arduino_VCC
Wire Wire Line
	2750 1900 4450 1900
Wire Wire Line
	2750 1900 2750 2400
Text GLabel 4450 3450 2    50   Output ~ 0
Arduino_GND
Wire Wire Line
	2750 3450 4450 3450
Wire Wire Line
	2750 3200 2750 3450
Wire Wire Line
	3000 1650 3200 1650
Wire Wire Line
	3200 1650 3200 2600
$EndSCHEMATC
