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
        echo "Proper eMMC partitionining not found!"
	exit 1
fi

#check_running_system
echo timer > /sys/class/leds/beaglebone\:green\:usr0/trigger 
sdcard="/sdcard"

image_filename_folder="${sdcard}/tmp"
image_filename_prfx="upgrade"
image_filename_rootfs="$image_filename_prfx-rootfs.img.gz" 
image_filename_data="$image_filename_prfx-data.img.gz"
image_filename_boot="$image_filename_prfx-boot.img.gz"
image_filename_pt="$image_filename_prfx-pt.img.gz"
image_filename_upgrade_tar_temp="${sdcard}/tmp/temp.tar"
image_filename_upgrade_temp="${sdcard}/tmp/temp.tar.gz"
image_filename_upgrade="${sdcard}/upgrade.img.gz"

if [ "$1" = "factorysettings" ]
then	
	echo "Factory settings image creation"
	image_filename_upgrade="${sdcard}/factory_settings.img.gz"
fi

echo "Packing eMMC image.."

if [ ! -e  ${sdcard} ]
then
	mkdir -p ${sdcard}
fi

umount ${sdcard} || true
mount ${sdcard_dev}p1 ${sdcard} -t vfat || true

cd $image_filename_folder

echo "Temp folder: $image_filename_folder"
ls

if [ -e  $image_filename_upgrade_tar_temp ]
then
	rm $image_filename_upgrade_tar_temp
fi

if [ -e $image_filename_upgrade_temp ]
then
	rm $image_filename_upgrade_temp
fi

if [ -e $image_filename_upgrade ]
then
	rm $image_filename_upgrade
fi

if [ ! -e ${sdcard}/tmp ]
then
        mkdir -p ${sdcard}/tmp/
fi

echo "Copying eMMC partitions at $eMMC"
sync
echo "Packing up partition table to: $image_filename_pt"
dd  if=${eMMC} bs=16M count=1 | gzip -c > $image_filename_pt

sleep 5
sync

if [ ! -e /tmp/emmc ]
then
	mkdir -p /tmp/emmc
fi

rootfs_partition=${eMMC}p2
data_partition=${eMMC}p3

mount $rootfs_partition /tmp/emmc -t ext4
retval=$?

#30 minutes of delay allowed syncing big zero files
echo 1800 > /proc/sys/kernel/hung_task_timeout_secs

if [ $retval -ne 0 ]; then
    echo "Error mounting rootfs partition! Error($retval)"
else
	echo "Zeroing rootfs partition"
	dd if=/dev/zero of=/tmp/emmc/big_zero_file1.bin bs=16M count=30> /dev/null
	result=$?
	sync &
	sleep 5

	if [ $result -eq 0 ]
	then
		dd if=/dev/zero of=/tmp/emmc/big_zero_file2.bin bs=16M count=30> /dev/null
		result=$?
		sync &
		sleep 5
	fi
	if [ $result -eq 0 ]
	then
		dd if=/dev/zero of=/tmp/emmc/big_zero_file3.bin bs=16M count=30> /dev/null
		result=$?
		sync &
		sleep 5
	fi
	if [ $result -eq 0 ]
	then
		dd if=/dev/zero of=/tmp/emmc/big_zero_file4.bin bs=16M> /dev/null
		sync &
		sleep 10
	fi

	sync
	echo "Removing zeros files"
	rm /tmp/emmc/big_zero_file*
	sync &
	sleep 10
	sync
	umount /tmp/emmc > /dev/null || true
fi

echo "Packing up binaries partition to: $image_filename_rootfs"
dd  if=${eMMC}p2 bs=16M | gzip -c > $image_filename_rootfs

sleep 5
sync

echo "Packing up boot partition to: $image_filename_boot"
dd  if=${eMMC}p1 bs=16M | gzip -c > $image_filename_boot

if [ "$1" = "factorysettings" ]
then
	echo "Data partition: $data_partition"
	umount /tmp/emmc>/dev/null || true
	mount $data_partition /tmp/emmc -t ext4

	retval=$?

	if [ $retval -ne 0 ]; then
	    echo "Error mounting data partition! Error($retval)"
	else
		echo "Zeroing data partition"
		dd if=/dev/zero of=/tmp/emmc/big_zero_file.bin > /dev/null
		sync &
		sleep 5
		sync

		echo "Removing zeros file"
		rm /tmp/emmc/big_zero_file.bin
		sync &
		sleep 10
		sync

		umount /tmp/emmc > /dev/null || true
	fi

	echo "Packing up data partition to: $image_filename_data"
	dd  if=${eMMC}p3 bs=16M | gzip -c > $image_filename_data

	#tarring
	echo "compressing all images to $image_filename_upgrade_tar_temp"
	tar -cvf $image_filename_upgrade_temp $image_filename_pt $image_filename_boot $image_filename_data $image_filename_rootfs

	if [ -e $image_filename_data ]
	then
		rm $image_filename_data
	else
       		echo "Data image not found: $image_filename_data"
	fi
else
	#tarring
	echo "compressing all images to $image_filename_upgrade_tar_temp"
	tar -cvf $image_filename_upgrade_temp $image_filename_pt $image_filename_boot $image_filename_rootfs
fi


#error handling needed..

echo "Remove packed files"
if [ -e $image_filename_boot ]
then
	rm $image_filename_boot
else
       	echo "Boot image not found: $image_filename_boot"
fi

if [ -e $image_filename_rootfs ]
then
	rm $image_filename_rootfs
else
        echo "Rootfs image not found: $image_filename_rootfs"
fi

if [ -e $image_filename_pt ]
then
	rm $image_filename_pt
fi

echo "Finalizing: $image_filename_upgrade"
echo "mv $image_filename_upgrade_temp $image_filename_upgrade"
mv $image_filename_upgrade_temp $image_filename_upgrade

echo "Finished.. byebye!"

if [ -e ${sdcard}/pack_resume_autorun.flag ]
then
	rm ${sdcard}/pack_resume_autorun.flag>/dev/null || true 
fi

echo 60 > /proc/sys/kernel/hung_task_timeout_secs

sync
echo default-on > /sys/class/leds/beaglebone\:green\:usr0/trigger

if [ -e $image_filename_upgrade ]
then
	exit 0
fi

exit 1
