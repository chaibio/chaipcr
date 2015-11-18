#!/bin/sh

id | grep -q root
is_root=$?
#echo $is_root

if [ ! $is_root ]
then
	echo "must be run as root"
	exit
fi

if [ -e /dev/mmcblk0p4 ]
then
        eMMC=/dev/mmcblk0
	sdcard_dev=/dev/mmcblk1p1
elif [ -e /dev/mmcblk1p4 ]
then
       	eMMC=/dev/mmcblk1
	sdcard_dev=/dev/mmcblk0p1
else
       	echo "4 partitions eMMC not found!"
	echo default-on > /sys/class/leds/beaglebone\:green\:usr0/trigger 
	exit
fi

sync

if [ ! -e /sdcard ]
then
	mkdir /sdcard
fi

if [ ! -e /emmcboot ]
then
	mkdir /emmcboot
fi

umount /sdcard > /dev/null || true
mount $sdcard_dev /sdcard || true

sdcard="/sdcard"

flush_cache () {
	sync
}

flush_cache_mounted () {
	sync
#	blockdev --flushbufs ${eMMC} || true
}

write_rootfs_image () {
	echo "Writing rootfs partition image!"
	echo timer > /sys/class/leds/beaglebone\:green\:usr0/trigger
        gunzip -c ${sdcard}/factory_settings-rootfs.img.gz | dd of=${eMMC}p2 bs=16M
	echo default-on > /sys/class/leds/beaglebone\:green\:usr0/trigger
	echo "Done writing rootfs partition image!"
}

write_data_image () {
        echo "Writing data partition image!"
        echo timer > /sys/class/leds/beaglebone\:green\:usr0/trigger
        gunzip -c ${sdcard}/factory_settings-data.img.gz | dd of=${eMMC}p3 bs=16M
        echo default-on > /sys/class/leds/beaglebone\:green\:usr0/trigger
        echo "Done writing data partition image!"
}

write_boot_image () {
	echo "Writing boot partition image!"
	echo timer > /sys/class/leds/beaglebone\:green\:usr0/trigger
	gunzip -c ${sdcard}/factory_settings-boot.img.gz | dd of=${eMMC}p1 bs=16M
	echo default-on > /sys/class/leds/beaglebone\:green\:usr0/trigger
	echo "Done writing boot partition image!"
}

write_pt_image () {
	echo "Writing partition table!"
	echo timer > /sys/class/leds/beaglebone\:green\:usr0/trigger
	gunzip -c ${sdcard}/factory_settings-pt.img.gz | dd of=${eMMC} bs=16M
	echo default-on > /sys/class/leds/beaglebone\:green\:usr0/trigger
	echo "Done writing partition table!"
}

alldone () {
#	exit

	if [ -e /sys/class/leds/beaglebone\:green\:usr0/trigger ] ; then
		echo default-on > /sys/class/leds/beaglebone\:green\:usr0/trigger
		echo default-on > /sys/class/leds/beaglebone\:green\:usr1/trigger
		echo default-on > /sys/class/leds/beaglebone\:green\:usr2/trigger
		echo default-on > /sys/class/leds/beaglebone\:green\:usr3/trigger
	fi

	echo "Done!"
#exit

	echo "-----------------------------"
	echo "Note: Please unpower the board, a reset [sudo reboot] is not enough."
	echo "-----------------------------"

	echo "Shutting Down..."
	sync
	halt
}

update_uenv () {
	echo copying coupling uEng.txt
	mount ${eMMC}p1 /emmcboot || true
	cp /sdcard/uEnv.txt /emmcboot/
	sync
	sleep 5	
	umount /emmcboot || true
}

if [ -e ${sdcard}/upgrade_resume_autorun.flag ]
then
	echo "Resuming incomplete upgrade!"
	sync
	rm ${sdcard}/upgrade_resume_autorun.flag
	sh /sdcard/unpack_latest_version.sh || true
	update_uenv
	alldone
	exit
fi

if [ ! -e ${sdcard}/factory_settings-pt.img.gz ]
then
	echo "Creating factory settings images! Copying from eMMC at $eMMC to sdcard at $sdcard_dev!"
	sh /sdcard/make_factory_settings_sdcard.sh || true
	sync
	update_uenv
	alldone
	exit
fi

echo "Copying from sdcard at $sdcard_dev to eMMC at $eMMC!"

echo "eMMC Flasher: writing to partition table"

if [ -e ${sdcard}/factory_settings-pt.img.gz ]
then
	write_pt_image
	flush_cache
	flush_cache_mounted
fi

if [ -e "${eMMC}p4" ]
then
        echo "Perminant data partition found! bypassing repartitioning!"
else
	echo "Repartitioning needed!"
        alldone
	exit
fi

echo "eMMC Flasher: Creating boot partition"
if [ -e ${sdcard}/factory_settings-boot.img.gz ]
then
        write_boot_image
fi

update_uenv

echo "eMMC Flasher: writing to data partition"
if [ -e ${sdcard}/factory_settings-data.img.gz ]
then
        write_data_image
fi

echo "eMMC Flasher: writing to rootfs partition"
if [ -e ${sdcard}/factory_settings-rootfs.img.gz ]
then
	write_rootfs_image
fi

echo "eMMC Flasher: all done!"
sync
sleep 5
umount /sdcard || true 
umount /emmc || true
echo "Done!"
alldone

