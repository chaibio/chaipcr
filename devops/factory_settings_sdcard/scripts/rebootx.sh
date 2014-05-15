#!/bin/bash

wait_and_reboot () {
	sync &
	sleep 2
	reboot
}

#wait 2 seconds before rebooting to be able to report the reboot to user.
wait_and_reboot &

timeout=120
if [ -z $1 ]
then
	echo "No timeout given. Defaulting to $timeout"
else
	timeout=$1
	echo "waiting for $timeout seconds before forcing reboot"
fi

reboot_after_timeout () {
	sleep $timeout
	echo "Reboot timeoutted!"
	reboot -n -f
}

reboot_after_timeout &

exit 0
