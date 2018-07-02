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

exit_with_message () {
	echo "UPGRADE: $1"
	if [ ! -z "$3" ]
	then
		echo Writing results to $3
		echo "$1" >> $3
	fi
	exit $2
}

if ! id | grep -q root; then
	exit_with_message "must be run as root" 5 $1
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
        exit_with_message "Proper eMMC partitionining not found!" 1 $1
fi

eMMC_boot=${eMMC}p1
eMMC_root=${eMMC}p2
eMMC_data=${eMMC}p3
eMMC_perm=${eMMC}p4
uEnvPath=/tmp/uEnvPath

if [ -e $eMMC_perm ]
then
	echo four partitions system
else
	eMMC_boot=
	eMMC_root=${eMMC}p1
	eMMC_data=${eMMC}p2
	eMMC_perm=${eMMC}p3
fi

if [ ! -e $emmc_boot_files ]
then
	mkdir -p $emmc_boot_files
fi

verify_checksum () {
        image_filename_upgrade1="/sdcard/upgrade/upgrade.img.tar"
	if [ ! -e $image_filename_upgrade1 ]
	then
		exit_with_message "Upgrade image not found!" 2 $1
	fi

	image_filename_prfx="upgrade"
	image_filename_rootfs="$image_filename_prfx-rootfs.img.gz"
	image_filename_data="$image_filename_prfx-data.img.gz"
	image_filename_boot="$image_filename_prfx-boot.img.gz"
	image_filename_pt="$image_filename_prfx-pt.img.gz"
	checksums_filename="$image_filename_prfx-checksums.txt"

	check_sum=$( tar xOf $image_filename_upgrade1 $checksums_filename )
	if [ -z "$check_sum" ]
	then
		exit_with_message "Incompatable upgrade image: No checksum file found!" 4 $1
	fi
	echo "Checksums: $check_sum"

	files_tocheck=( "$image_filename_pt" "$image_filename_boot" "$image_filename_rootfs" )

	for fl in "${files_tocheck[@]}"
	do
		echo "Checking $fl"
		file_checksum=$( tar xOf $image_filename_upgrade1 $fl | md5sum | awk '{ print $1 }' )
		echo "Calculated checksum: $file_checksum"
		if [[ $check_sum == *"$file_checksum"* ]]
		then
			echo "Checksum ok!"
		else
			exit_with_message "Checksum error!" 6 $1
		fi
	done
}

BASEDIR=$(dirname $0)

echo timer > /sys/class/leds/beaglebone\:green\:usr0/trigger
echo "Verifying.."
verify_checksum

reset_s2 () {
	echo "Resetting s2 button!"
	echo 72 > /sys/class/gpio/export
	cat /sys/class/gpio/gpio72/value
	echo out > /sys/class/gpio/gpio72/direction
	echo 0 > /sys/class/gpio/gpio72/value
	cat /sys/class/gpio/gpio72/value	
	echo 72 > /sys/class/gpio/unexport
}

set_sdcard_uEnv () {
	if [ -e ${uEnvPath}/uEnv.txt ]
	then
		echo Processing ${uEnvPath}/uEnv.txt
	else
		return 1
	fi
	cp ${uEnvPath}/uEnv.txt ${uEnvPath}/uEnv.org.txt
	sync
	file1=${uEnvPath}/uEnv.sdcard.txt
	file2=${uEnvPath}/uEnv.txt
	cp $file1 $file2
	echo verifying $file1 and $file2

	for a in 1 2 3 4 5
	do
		echo Verify uEnv update.. check# $a of 5

		if cmp -s $file1 $file2
		then
			echo updating uEnv done.
			break
		fi
		cp $file1 $file2
		sync
		sleep 10
	done

	sleep 3
	sync
}

reset_sdcard_uEnv () {
	cp ${uEnvPath}/uEnv.org.txt ${uEnvPath}/uEnv.txt
	sync
}


if [ ! -e "$uEnvPath" ]
then
	mkdir -p ${uEnvPath} > /dev/null
fi

if [ -z $eMMC_boot ]
then
 	echo none fat boot
else
	#umount ${uEnvPath} > /dev/null
	mount ${eMMC_boot} ${uEnvPath} -t vfat
	set_sdcard_uEnv
	sync
	umount ${uEnvPath}> /dev/null
fi

mount ${sdcard_dev}p1 ${uEnvPath} -t vfat
set_sdcard_uEnv
sync
sleep 5
umount ${uEnvPath}

mount ${sdcard_dev}p2 ${uEnvPath}
NOW=$(date +"%m-%d-%Y %H:%M:%S")
echo "Resume flag up at $NOW"
echo "Upgrade started at: $NOW">${uEnvPath}/unpack_resume_autorun.flag
echo "Upgrade initiated at: $NOW">${uEnvPath}/booting.log
echo "1">${uEnvPath}/restart_counter.ini
echo "1">${uEnvPath}/unpack_stage.ini
sync
sleep 5
umount ${uEnvPath}

uEnvPath=/boot/uboot
mount -o remount,rw ${uEnvPath}
set_sdcard_uEnv
sync

uEnvPath=/boot
mount -o remount,rw ${uEnvPath}
set_sdcard_uEnv
sync

uEnvPath=/sdcard/factory
mount -o remount,rw ${uEnvPath}

echo "Checking if factory settings scripts should be upgraded..."
version_file=/sdcard/factory/fs_Version.inf
version_current=0
if [ -e ${version_file} ]
then
	version_current=$(cat ${version_file})
fi

version_upgrade=0
if [ -e /sdcard/upgrade/upgrade.img.tar ]
then
	version_upgrade=$(tar -xf /sdcard/upgrade/upgrade.img.tar factory-scripts/fs_version.inf --to-stdout)
	echo current factory settings scripts version $version_current, upgrade image version is $version_upgrade
	if [ $version_current -lt $version_upgrade ]
	then
		echo upgrading factory settings scripts
		cd /sdcard/factory/
		tar -xf /sdcard/upgrade/upgrade.img.tar factory-scripts
		cp -r factory-scripts/* .
		sync
		sleep 3
		rm -r factory-scripts
		echo done extracting.
	else
		echo No factory settings partition upgrade needed
	fi
fi

set_sdcard_uEnv
sync

sleep 5

echo "Restarting to packing eMMC image.."
echo default-on > /sys/class/leds/beaglebone\:green\:usr0/trigger

if [ -e /data/.tmp/shadow.backup ]
then
	rm /data/.tmp/shadow.backup
else
	if [ ! -e /data/.tmp/ ]
	then
	        mkdir -p /data/.tmp/
	fi
fi

cp /etc/shadow /data/.tmp/shadow.backup

if [ -e /data/.tmp/dhclient.*.leases ]
then
	rm /data/.tmp/dhclient.*.leases
fi

cp /var/lib/dhcp/dhclient.*.leases /data/.tmp/
sync

reset_s2

sh $BASEDIR/rebootx.sh
exit_with_message Success 0 $1
