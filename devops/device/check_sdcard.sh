#!/bin/bash

if ! id | grep -q root; then
	echo "must be run as root"
	exit 1
fi

if [ -e /dev/mmcblk1p4 ] ; then
	sdcard_dev="/dev/mmcblk0"
	eMMC="/dev/mmcblk1"
fi

if [ -e /dev/mmcblk0p4 ] ; then
	sdcard_dev="/dev/mmcblk1"
	eMMC="/dev/mmcblk0"
fi

if [ ! -e "${eMMC}p4" ]
then
        echo "Proper partitionned eMMC not found!"
	exit 1
fi

all_done () {
	if [ -e /tmp/checked_partition/write_test.txt ]
	then
		rm /tmp/checked_partition/write_test.txt
	fi

	umount /tmp/checked_partition
	if [ -e /tmp/checked_partition ]
	then
		rm -r /tmp/checked_partition
		if [ $? -gt 0 ]
		then
			echo Cannt remove /tmp/checked_partition !
		fi
	fi
}

end_error () {
	all_done

	echo "Trying to format ${sdcard_dev}p2"
	umount ${sdcard_dev}p2 || true
	umount ${sdcard_dev}p2 || true
	mkfs.ext4 ${sdcard_dev}p2 -L UPGRADE

	if [ $? -eq 0 ]
	then
		echo "Partition formated successfully."
		if [ -e /sdcard/upgrade ]
		then
			mount ${sdcard_dev}p2 /sdcard/upgrade -t ext4
			if [ $? -eq 0 ]
			then
				echo "Partition remounted successfully to /sdcard/upgrade"
			else
				echo "Error remounting to /sdcard/upgrade/"
			fi
		fi

		exit 0
	else
		echo "Error formating ${sdcard_dev}p2"
	fi

	exit 1
}

if [ ! -e /tmp/checked_partition ]
then
	mkdir -p /tmp/checked_partition

	if [ $? -gt 0 ]
	then
		echo "Cannt create folder /tmp/checked_partition"
		end_error
	fi
fi

# todo check for mounting and unmound if mounted!
mount ${sdcard_dev}p2 /tmp/checked_partition
if [ $? -gt 0 ]
then
	echo "Cannt mount to /tmp/checked_partition"
	end_error
fi

NOW=$(date +"%m-%d-%Y %H:%M:%S")

echo $NOW>/tmp/checked_partition/write_test.txt
if [ $? -gt 0 ]
then
	echo "Cannt write to /tmp/checked_partition"
	end_error
fi

read_text=$(cat /tmp/checked_partition/write_test.txt)
if [ $? -gt 0 ]
then
	echo "Cannt read from /tmp/checked_partition/write_test.txt"
	end_error
fi

if [ "$NOW" = "$read_text" ]
then
	echo "Partition is read/write OK.. exit."
else
	echo "Error reading from /tmp/checked_partition/write_test.txt.. wrote text: $NOW, read text: $read_text"
	end_error
fi

all_done

exit 0
