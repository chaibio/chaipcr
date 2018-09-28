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
	exit 0
fi

if [ -e /dev/mmcblk1p3 ] ; then
	sdcard_dev="/dev/mmcblk0"
	eMMC="/dev/mmcblk1"
fi

if [ -e /dev/mmcblk0p3 ] ; then
	sdcard_dev="/dev/mmcblk1"
	eMMC="/dev/mmcblk0"
fi

if [ ! -e "${eMMC}p3" ]
then
        echo "Proper eMMC partitionining not found!"
	exit 1
fi

echo timer > /sys/class/leds/beaglebone\:green\:usr0/trigger
sdcard="/sdcard"

set_sdcard_uEnv () {
	cp ${uEnvPath}/uEnv.txt ${uEnvPath}/uEnv.org.txt
	cp ${uEnvPath}/uEnv.sdcard.txt ${uEnvPath}/uEnv.txt
	sync
}

reset_sdcard_uEnv () {
	cp ${uEnvPath}/uEnv.org.txt ${uEnvPath}/uEnv.txt
	sync
}

uEnvPath=/tmp/uEnvPath
mkdir -p ${uEnvPath} > /dev/null

umount ${uEnvPath} > /dev/null
mount ${eMMC}p1 ${uEnvPath} -t vfat
set_sdcard_uEnv
umount ${uEnvPath}> /dev/null

mount ${sdcard_dev}p1 ${uEnvPath} -t vfat
set_sdcard_uEnv

NOW=$(date +"%m-%d-%Y %H:%M:%S")
echo "Resume flag up at $NOW"
echo "Upgrade started at: $NOW">${uEnvPath}/pack_resume_autorun.flag
echo "1">${uEnvPath}/restart_counter.ini
umount ${uEnvPath}

echo "Restarting to packing eMMC image.."
echo default-on > /sys/class/leds/beaglebone\:green\:usr0/trigger

reboot
exit 0
