#!/bin/bash

retval = 0
test_mux () {
	if cat $PINS | grep -i $2 | grep -i $3 > /dev/zero
	then
		echo Testing $1: OK 
	else
                echo Testing $1: Error
		retval=1
	fi
}

echo PWM:
test_mux "pin 9_28" 99c 00000004
test_mux "pin 8_13" 824 00000004
test_mux "pin 8_19" 820 00000004
test_mux "pin 9_42" 964 00000000
test_mux "pin 9_14" 848 00000006
test_mux "pin 9_16" 84c 00000006

echo SPI:
test_mux "pin101" 994 00000033


echo SPI0 LTC2444:
test_mux "pin 9.21" 954 00000030
test_mux "pin 9.18" 958 00000010
test_mux "pin 9.22" 950 00000030
test_mux "pin 9.17" 95C 00000010


echo Peltier:
test_mux "pin 8.13" 824 00000004
test_mux "pin 8.19" 820 00000004

test_mux "pin 8.9 "  89c 0000000F
test_mux "pin 8.11" 834 0000000F
test_mux "pin 8.15" 83C 0000000F
test_mux "pin 8.17" 82C 0000000F


echo LED board:
test_mux "pin 9.16" 84c 00000006
test_mux "pin 8.18" 88C 00000017
test_mux "pin 8.12" 830 00000017
test_mux "pin 8.14" 828 0000000F
test_mux "pin 8.8 "  894 00000037

echo SPI1 LED Board:
test_mux "pin 9.29" 994 00000033
test_mux "pin 9.30" 998 00000013
test_mux "pin 9.31" 990 00000033


echo MCU:
test_mux "pin 8.10" 898 00000017


echo LIA MUX:
test_mux "pin 9.11" 870 00000007
test_mux "pin 9.13" 874 00000007
test_mux "pin 9.15" 840 00000007
test_mux "pin 9.12" 878 00000007


echo LID:
#test_mux "pin 8.26" 994 00000033
test_mux "pin 9.28"  99c 00000004


echo Heatsink:
test_mux "pin 9.14 PWM" 848 00000006
#test_mux "pin 9.39" 994 00000033
#test_mux "pin 9.40" 994 00000033
#test_mux "pin 9.37" 994 00000033
#test_mux "pin 9.38" 994 00000033
#test_mux "pin 9.33" 994 00000033
#test_mux "pin 9.36" 994 00000033
#test_mux "pin 9.35" 994 00000033

echo LTC2444:
test_mux "pin 9.41.1 SPI_BUSY" 8B4 00000037
test_mux "pin 9.41.2 shared with SPI_BUSY or LTC2444 busy gpio0_20" 8A8 00000037


echo LCD:
test_mux "pin 8.45"  8a0 00000008
test_mux "pin 8.46"  8a4 00000008
test_mux "pin 8.43"  8a8 00000008
test_mux "pin 8.44"  8ac 00000008
test_mux "pin 8.41"  8b0 00000008
test_mux "pin 8.42"  8b4 00000008
test_mux "pin 8.49"  8b8 00000008
test_mux "pin 8.40"  8bc 00000008
test_mux "pin 8.37"  8c0 00000008
test_mux "pin 8.38"  8c4 00000008
test_mux "pin 8.36"  8c8 00000008
test_mux "pin 8.34"  8cc 00000008
test_mux "pin 8.35"  8d0 00000008
test_mux "pin 8.33"  8d4 00000008
test_mux "pin 8.31"  8d8 00000008
test_mux "pin 8.32"  8dc 00000008

test_mux "pin 8.27 vsync"  8e0 00000000
test_mux "pin 8.29 hsync"  8e4 00000000
test_mux "pin 8.28 pclk"  8e8 00000000
test_mux "pin 8.30 ac  "  8ec 00000000

test_mux "gpio1_17 Touch P9.23"  844 0000002f
test_mux "pin 9.27 gpio3_19 LCD DISEN"  9a4 00000017

echo Backlight:
test_mux "pin 9.42.1 eCAP0"  964 00000000


exit $retval
