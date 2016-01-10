#!/bin/bash

reboot &

timeout=120
if [ -z $1 ]
then
	echo "No timeout given. Defaulting to $timeout"
else
	echo "waiting for $timeout seconds before forcing reboot"
	timeout=$1
fi
sleep $timeout

echo "Reboot timeoutted!"
reboot -n -f -d 5


