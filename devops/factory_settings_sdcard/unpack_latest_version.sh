#!/bin/bash

if ! id | grep -q root; then
	echo "must be run as root"
	exit 0
fi

#unset boot_drive
#boot_drive=$(LC_ALL=C lsblk -l | grep "/boot/uboot" | awk '{print $1}')

#if [ "x${boot_drive}" = "x" ] ; then
#	echo "Error: script halting, system unrecognized..."
#	exit 1
#fi

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
        echo "Proper partitionining not found!"
	exit 1
fi

unmount_emmc () {
echo "Prevent writing to eMMC"
#umount -l /boot/uboot

mount -o ro,remount /dev/mmcblk1p1

lsblk
fuser -wkm /dev/mmcblk1p2 && mount -o ro,remount /dev/mmcblk1p2

#fuser -km ${eMMC}p2
#umount -l ${eMMC}p2

lsblk
#exit
}


flush_cache_mounted () {
	sync
	blockdev --flushbufs ${eMMC}
}

#
#check_running_system () {
#	if [ ! -f /boot/uboot/uEnv.txt ] ; then
#		echo "Error: script halting, system unrecognized..."
#		echo "unable to find: [/boot/uboot/uEnv.txt] is ${sdcard_dev}p1 mounted?"
#		exit 1
#	fi

#	echo "-----------------------------"
#	echo "debug copying: [${sdcard_dev}] -> [${eMMC}]"
#	lsblk
#	echo "-----------------------------"
#
#	if [ ! -b "${eMMC}" ] ; then
#		echo "Error: [${eMMC}] does not exist"
#		exit 1
#	fi
#}

write_pt_image () {
	echo "Writing partition table image!"
	echo timer > /sys/class/leds/beaglebone\:green\:usr0/trigger
        gunzip -c $image_filename_pt | dd of=${eMMC} bs=16M
	flush_cache_mounted
	echo default-on > /sys/class/leds/beaglebone\:green\:usr0/trigger
	echo "Done writing partition table image!"
}

write_rootfs_image () {
	echo "Writing rootfs partition image!"
	echo timer > /sys/class/leds/beaglebone\:green\:usr0/trigger
        gunzip -c $image_filename_rootfs | dd of=${eMMC}p2 bs=16M
	flush_cache_mounted
	echo default-on > /sys/class/leds/beaglebone\:green\:usr0/trigger
	echo "Done writing rootfs partition image!"
}

write_data_image () {
        echo "Writing data partition image!"
        echo timer > /sys/class/leds/beaglebone\:green\:usr0/trigger
        gunzip -c $image_filename_data | dd of=${eMMC}p3 bs=16M
	flush_cache_mounted
        echo default-on > /sys/class/leds/beaglebone\:green\:usr0/trigger
        echo "Done writing data partition image!"
}

write_boot_image () {
	echo "Writing boot partition image!"
	echo timer > /sys/class/leds/beaglebone\:green\:usr0/trigger
	gunzip -c $image_filename_boot | dd of=${eMMC}p1 bs=16M
	flush_cache_mounted
	echo default-on > /sys/class/leds/beaglebone\:green\:usr0/trigger
	echo "Done writing boot partition image!"
}

extract_image_files () {

if [ -e  $image_filename_upgrade_tar_temp ]
then
	rm $image_filename_upgrade_tar_temp
fi

if [ -e $image_filename_upgrade_temp ]
then
	rm $image_filename_upgrade_temp
fi

cp $image_filename_upgrade $image_filename_upgrade_temp

echo "Untar upgrade tar from $image_filename_upgrade_temp"
#gunzip $image_filename_upgrade_temp

#echo "uncompressing tar ball from $image_filename_upgrade_tar_temp to $image_filename_upgrade_temp_folder"
cd $image_filename_upgrade_tar_temp_folder
tar -xvf $image_filename_upgrade_temp
# --directory $image_filename_upgrade_tar_temp_folder

#exit

#rm $image_filename_upgrade_tar_temp


if [ -e  $image_filename_upgrade_tar_temp ]
then
        rm $image_filename_upgrade_tar_temp
fi

if [ -e $image_filename_upgrade_temp ]
then
        rm $image_filename_upgrade_temp
fi





echo "Writing images to eMMC!"
}

#check_running_system

echo timer > /sys/class/leds/beaglebone\:green\:usr0/trigger

#echo "Debug copy!"
#cp ../../backup/upgrade.img.gz ../../

sdcard="/sdcard"

image_filename_prfx="${sdcard}/tmp/upgrade"
image_filename_rootfs="$image_filename_prfx-rootfs.img.gz" 
image_filename_data="$image_filename_prfx-data.img.gz"
image_filename_boot="$image_filename_prfx-boot.img.gz"
image_filename_pt="$image_filename_prfx-pt.img.gz"
image_filename_upgrade_tar_temp="${sdcard}/tmp/temp.tar"
image_filename_upgrade_temp="${sdcard}/tmp/temp.tar.gz"
image_filename_upgrade_tar_temp_folder="${sdcard}/tmp/"

image_filename_upgrade="${sdcard}/upgrade.img.gz"

if [ ! -e ${sdcard}/tmp/ ]
then
       mkdir -p ${sdcard}/tmp/
fi

umount ${sdcard} || true
mount ${sdcard_dev}p1 ${sdcard} || true

NOW=$(date +"%m-%d-%Y %H:%M:%S")
echo "Upgrade resume flag up!"
echo "Upgrade started at: $NOW">>${sdcard}/unpack_resume_autorun.flag

#exit 0

echo "Unpacking eMMC image.."

if [ ! -e ${sdcard}/tmp/ ]
then
       mkdir -p ${sdcard}/tmp/
fi

if [ ! -e  $image_filename_upgrade ]
then
	echo "Uprade image not found: $image_filename_upgrade.. exit!"
#	echo "Upgrade resume flag down!"
	rm ${sdcard}/unpack_resume_autorun.flag

	echo default-on > /sys/class/leds/beaglebone\:green\:usr0/trigger
	echo default-on > /sys/class/leds/beaglebone\:green\:usr1/trigger

	exit 0
fi

extract_image_files

if [ -e $image_filename_boot ]
then
        write_boot_image
	rm $image_filename_boot
else
       	echo "Boot image not found: $image_filename_boot"
fi

if [ -e $image_filename_rootfs ]
then
	write_rootfs_image
	rm $image_filename_rootfs
else
        echo "Rootfs image not found: $image_filename_rootfs"
fi

if [ -e $image_filename_pt ]
then
        write_pt_image
	rm $image_filename_pt
else
	echo "Partition table image not found!"
fi

#exit

echo "Finished.. byebye!"
echo "Upgrade resume flag down!"
rm ${sdcard}/unpack_resume_autorun.flag || true

sync
echo default-on > /sys/class/leds/beaglebone\:green\:usr0/trigger

if [ $# -eq 0 ]
then
	reboot
fi


exit 0
