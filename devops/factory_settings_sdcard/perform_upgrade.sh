#!/bin/bash

if ! id | grep -q root; then
	echo "must be run as root"
	exit 0
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
echo "Upgrade started at: $NOW">${uEnvPath}/unpack_resume_autorun.flag
echo "1">${uEnvPath}/restart_counter.ini
echo "1">${uEnvPath}/unpack_stage.ini

umount ${uEnvPath}

echo "Restarting to packing eMMC image.."
#reboot

echo default-on > /sys/class/leds/beaglebone\:green\:usr0/trigger

reboot

exit 0
