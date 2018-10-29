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

#exit 0

debug=1
BASEDIR=$(dirname $0)

if [ $debug -eq 1 ]
then
	NOW=$(date +"%m-%d-%Y %H:%M:%S")
	log_file=/mnt/booting.log

	mkdir /tmp/upgrade -p
	if [ -e /dev/mmcblk0p3 ]
	then
        	eMMC=/dev/mmcblk0
		sdcard_dev=/dev/mmcblk1
		mount ${sdcard_dev}p2 /tmp/upgrade
		log_file=/tmp/upgrade/booting.log
	elif [ -e /dev/mmcblk1p3 ]
	then
       		eMMC=/dev/mmcblk1
		sdcard_dev=/dev/mmcblk0
		mount ${sdcard_dev}p2 /tmp/upgrade
		log_file=/tmp/upgrade/booting.log
	else
       		echo "3 or 4 partitions eMMC not found!"

		eMMC=/dev/mmcblk1
		sdcard_dev=/dev/mmcblk0
		mount ${sdcard_dev}p2 /tmp/upgrade
		log_file=/tmp/upgrade/booting.log

	fi

	echo "Logging boot to: $log_file.. timestamp: $NOW"
	echo "==== New boot at: $NOW" >> $log_file
	echo "==== Checking if factory settings scripts should be upgraded" >> $log_file

	version_file=/mnt/fs_Version.inf
	version_current=0
	if [ -e ${version_file} ]
	then
		version_current=$(cat ${version_file})
	fi

	version_upgrade=$(tar -xf /tmp/upgrade/upgrade.img.tar factory-scripts/fs_version.inf --to-stdout)
	echo current factory settings scripts version $version_current, upgrade image version is $version_upgrade
	echo current factory settings scripts version $version_current, upgrade image version is $version_upgrade  >> $log_file 2>&1
	if [ $version_current -lt $version_upgrade ]
	then
		echo upgrading factory settings scripts  >> $log_file 2>&1
		cd /mnt
		tar -xf /tmp/upgrade/upgrade.img.tar factory-scripts
		cp -r factory-scripts/* .
		echo done extracting.  >> $log_file 2>&1
	fi

	sh /mnt/autorun_core.sh  >> $log_file 2>&1
	result=$?
	echo "Boot with logging complete!"
	tail $log_file
else
	sh /mnt/autorun_core.sh
	result=$?
fi

exit $result
