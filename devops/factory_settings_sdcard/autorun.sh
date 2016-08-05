#!/bin/sh
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

debug=1
BASEDIR=$(dirname $0)

if [ $debug -eq 1 ]
then
	NOW=$(date +"%m-%d-%Y %H:%M:%S")
	log_file=/mnt/booting.log

	mkdir /tmp/rw -p
	if [ -e /dev/mmcblk0p3 ]
	then
        	eMMC=/dev/mmcblk0
		sdcard_dev=/dev/mmcblk1
		mount ${sdcard_dev}p2 /tmp/rw
		log_file=/tmp/rw/booting.log
	elif [ -e /dev/mmcblk1p3 ]
	then
       		eMMC=/dev/mmcblk1
		sdcard_dev=/dev/mmcblk0
		mount ${sdcard_dev}p2 /tmp/rw
		log_file=/tmp/rw/booting.log
	else
       		echo "4 partitions eMMC not found!"
	fi

	echo "Logging boot to: $log_file.. timestamp: $NOW"
	echo "==== New boot at: $NOW" >> $log_file
	sh /mnt/autorun_core.sh  >> $log_file 2>&1
	result=$?
	echo "Boot with logging complete!"
	tail $log_file
else
	sh /mnt/autorun_core.sh
	result=$?
fi

exit $result