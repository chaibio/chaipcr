#!/bin/bash
#
# Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
# For more information visit http://www.chaibio.com
#
# Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

if ! id | grep -q root; then
	echo "must be run as root"
	exit 1
fi

if [ -e /dev/mmcblk1p3 ] ; then
	sdcard_dev="/dev/mmcblk0"
	eMMC="/dev/mmcblk1"
fi

if [ -e /dev/mmcblk0p3 ] ; then
	sdcard_dev="/dev/mmcblk1"
	eMMC="/dev/mmcblk0"
fi

exit_with_message () {
	echo $1
	exit 1
}

if [ ! -e "${eMMC}p3" ]
then
        exit_with_message "Proper eMMC partitionining not found!"
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

format_upgrade_exit () {
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
		exit_with_message "Cannt create folder /tmp/checked_partition"
	fi
fi

# todo check for mounting and unmound if mounted!
mount ${sdcard_dev}p2 /tmp/checked_partition
if [ $? -gt 0 ]
then
	echo "Cannt mount to /tmp/checked_partition"
	format_upgrade_exit
fi

NOW=$(date +"%m-%d-%Y %H:%M:%S")

echo $NOW>/tmp/checked_partition/write_test.txt
if [ $? -gt 0 ]
then
	echo "Cannt write to /tmp/checked_partition"
	format_upgrade_exit
fi

read_text=$(cat /tmp/checked_partition/write_test.txt)
if [ $? -gt 0 ]
then
	echo "Cannt read from /tmp/checked_partition/write_test.txt"
	format_upgrade_exit
fi

if [ "$NOW" = "$read_text" ]
then
	echo "Partition is read/write OK.. exit."
else
	echo "Error reading from /tmp/checked_partition/write_test.txt.. wrote text: $NOW, read text: $read_text"
	format_upgrade_exit
fi

all_done

exit 0