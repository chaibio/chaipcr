#!/bin/bash

reboot &
sync &

timeout=120
if [ -z $1 ]
then
	echo "No timeout given. Defaulting to $timeout"
else
	timeout=$1
	echo "waiting for $timeout seconds before forcing reboot"
fi
sleep $timeout

echo "Reboot timeoutted!"
reboot -n -f
