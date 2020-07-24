#!/bin/sh

reboot_needed=1

set_touch_driver () {
	lib=$1
	reboot_needed=1
	echo "Setting $lib touch controller"
	if [ -e /lib/modules/$(uname -r)/kernel/drivers/input/touchscreen/$lib.ko ]
	then
		if grep $lib /etc/modules-load.d/chaibio_touch_controller.conf
		then
			reboot_needed=1
		else
                        reboot_needed=0
		fi
		echo $lib>/etc/modules-load.d/chaibio_touch_controller.conf
	else
		echo Touch driver not found $lib
	fi
	return $reboot_needed
}

setup_touch_controller_by_i2c() {

	if [ -e /perm/device.json ]
	then
		echo device.json found
	else
		echo mounting /perm
		if [ -e /dev/mmcblk1p3 ]
		then
			mount /dev/mmcblk1p3 /perm || true
		fi
	fi

	if [ -e /perm/device.json ]
	then
		if grep ilitek_aimv20 /perm/device.json
        	then
               		set_touch_driver ilitek_aimv20
  		elif grep ft5x0x_ts /perm/device.json
        	then
                	set_touch_driver ft5x0x_ts
	        else
        	        echo "Touch driver directive not found in device.json"
		fi
	else
		echo "Cannot find /perm/device.json"
		if [ -d /sys/class/i2c-dev/i2c-2/device/2-0041 ]
		then
			set_touch_driver ilitek_aimv20
			exit $reboot_needed
		elif [ -d /sys/class/i2c-dev/i2c-2/device/2-0038 ]
		then
	        	set_touch_driver ft5x0x_ts
			exit $reboot_needed
		else
			echo No i2c representation.
		fi
	fi

	if [ $reboot_needed -eq 0 ]
	then
		echo Reboot needed
	fi

	exit $reboot_needed
}

setup_touch_controller_by_i2c

exit $reboot_needed
