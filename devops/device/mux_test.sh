#!/bin/bash

retval = 0
test_mux () {
	if cat $PINS | grep $2 | grep $3 > /dev/zero
	then
		echo Testing $1: OK 
	else
                echo Testing $1: Error
		retval=1
	fi
}

test_mux "pin 9_28" 99c 00000004
test_mux "pin 8_13" 824 00000004
test_mux "pin 8_19" 820 00000004
test_mux "pin 9_42" 964 00000000
test_mux "pin 9_14" 848 00000006
test_mux "pin 9_16" 84c 00000006

exit $retval
