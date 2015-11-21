#!/bin/sh

#exit

echo timer > /sys/class/leds/beaglebone\:green\:usr0/trigger

if [ -e /dev/mmcblk0p4 ]
then
        eMMC=/dev/mmcblk0
	sdcard=/dev/mmcblk1
elif [ -e /dev/mmcblk1p4 ]
then
       	eMMC=/dev/mmcblk1
	sdcard=/dev/mmcblk0
else
       	echo "4 partitions eMMC not found!"
	echo default-on > /sys/class/leds/beaglebone\:green\:usr0/trigger 
	exit
fi

sync
echo "Copying from eMMC at $eMMC to sdcard at $sdcard!"

image_filename_prfx="/sdcard/temp_factory_settings"
image_filename_rootfs="$image_filename_prfx-rootfs.img.gz"
image_filename_data="$image_filename_prfx-data.img.gz"
image_filename_boot="$image_filename_prfx-boot.img.gz"
image_filename_pt="$image_filename_prfx-pt.img.gz"
image_filename_perm="$image_filename_prfx-perm.img.gz"

if [ ! -e /sdcard ]
then
	mkdir /sdcard
fi

if [ ! -e /emmc ]
then
	mkdir /emmc
fi


if [ ! -e /emmcboot ]
then
        mkdir /emmcboot
fi

umount /sdcard > /dev/null || true
mount ${sdcard}p1 /sdcard

retval=$?

if [ $retval -ne 0 ]; then
    echo "Chai Factory Settings: Error mounting SDCard! Error($retval)"
#    exit
fi

echo "Removing previous images"

if [ -e $image_filename_rootfs ]
then
	rm -f $image_filename_pt
	rm -f $image_filename_perm
	rm -f $image_filename_rootfs
	rm -f $image_filename_data
	rm -f $image_filename_boot
fi

image_filename_prfx2="/sdcard/factory_settings"
image_filename_rootfs2="$image_filename_prfx2-rootfs.img.gz"
image_filename_data2="$image_filename_prfx2-data.img.gz"
image_filename_boot2="$image_filename_prfx2-boot.img.gz"
image_filename_pt2="$image_filename_prfx2-pt.img.gz"
image_filename_perm2="$image_filename_prfx2-perm.img.gz"

if [ -e $image_filename_rootfs2 ]
then
	rm -f $image_filename_pt2
	rm -f $image_filename_rootfs2
	rm -f $image_filename_data2
	rm -f $image_filename_boot2
	rm -f $image_filename_perm2
fi

rootfs_partition=${eMMC}p2
perm_partition=${eMMC}p4
data_partition=${eMMC}p3
echo "Data partition: $data_partition"

umount /emmc>/dev/null || true
mount $data_partition /emmc

retval=$?

if [ $retval -ne 0 ]; then
    echo "Error mounting data partition! Error($retval)"
else
	echo "Zeroing data partition"
	dd if=/dev/zero of=/emmc/big_zero_file.bin > /dev/null
	sync
	sleep 5
	sync
	sleep 10

	echo "Removing zeros file"
	rm /emmc/big_zero_file.bin
	sync
	umount /emmc > /dev/null || true
fi

finish() {
	sync
	umount /sdcard > /dev/null || true
	umount /emmc > /dev/null || true
	echo "Finished.. byebye!"
	sleep 15
	echo heartbeat > /sys/class/leds/beaglebone\:green\:usr0/trigger
	exit
}

echo "Backing up partition table to: $image_filename_pt"
dd  if=$eMMC bs=16M count=1 | gzip -c > $image_filename_pt

sleep 15
sync

echo "Backing up boot partition to: $image_filename_boot"
dd  if=${eMMC}p1 bs=16M | gzip -c > $image_filename_boot

sleep 15
sync

echo "Backing up data partition to: $image_filename_data"
dd  if=${eMMC}p3 bs=16M | gzip -c > $image_filename_data

sleep 15
sync

echo "Backing up perm partition to: $image_filename_perm"
dd  if=${eMMC}p4 bs=16M | gzip -c > $image_filename_perm

sleep 15
sync

echo "Backing up binaries partition to: $image_filename_rootfs"
dd  if=${eMMC}p2 bs=16M | gzip -c > $image_filename_rootfs

sleep 15
sync

mv $image_filename_rootfs $image_filename_rootfs2
mv $image_filename_data $image_filename_data2
mv $image_filename_boot $image_filename_boot2
mv $image_filename_pt $image_filename_pt2
mv $image_filename_perm $image_filename_perm2

sync

echo "creating factory settings images  done!!"

sleep 5

finish
