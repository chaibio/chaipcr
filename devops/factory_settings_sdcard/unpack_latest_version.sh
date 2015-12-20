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
        echo "Proper partitionining not found!"
	exit 1
fi

flush_cache_mounted () {
	sync
	command -v -- blockdev
	if [ $? -eq 0 ]
	then
		blockdev --flushbufs ${eMMC}
	fi
}

write_pt_image () {
	echo "Writing partition table image!"
	echo timer > /sys/class/leds/beaglebone\:green\:usr0/trigger
        tar xOf $image_filename_upgrade $image_filename_pt | gunzip -c | dd of=${eMMC} bs=16M
	flush_cache_mounted
	echo default-on > /sys/class/leds/beaglebone\:green\:usr0/trigger
	echo "Done writing partition table image!"
}

write_rootfs_image () {
	echo "Writing rootfs partition image!"
	echo timer > /sys/class/leds/beaglebone\:green\:usr0/trigger
        tar xOf $image_filename_upgrade $image_filename_rootfs | gunzip -c | dd of=${eMMC}p2 bs=16M
	flush_cache_mounted
	echo default-on > /sys/class/leds/beaglebone\:green\:usr0/trigger
	echo "Done writing rootfs partition image!"
}

write_data_image () {
        echo "Writing data partition image!"
        echo timer > /sys/class/leds/beaglebone\:green\:usr0/trigger
        tar xOf $image_filename_upgrade $image_filename_data | gunzip -c | dd of=${eMMC}p3 bs=16M
	flush_cache_mounted
        echo default-on > /sys/class/leds/beaglebone\:green\:usr0/trigger
        echo "Done writing data partition image!"
}

write_boot_image () {
	echo "Writing boot partition image!"
	echo timer > /sys/class/leds/beaglebone\:green\:usr0/trigger
	tar xOf $image_filename_upgrade $image_filename_boot | gunzip -c | dd of=${eMMC}p1 bs=16M
	flush_cache_mounted
	echo default-on > /sys/class/leds/beaglebone\:green\:usr0/trigger
	echo "Done writing boot partition image!"
}

echo timer > /sys/class/leds/beaglebone\:green\:usr0/trigger

sdcard="/sdcard"

image_filename_prfx="upgrade"
image_filename_rootfs="$image_filename_prfx-rootfs.img.gz" 
image_filename_data="$image_filename_prfx-data.img.gz"
image_filename_boot="$image_filename_prfx-boot.img.gz"
image_filename_pt="$image_filename_prfx-pt.img.gz"

image_filename_upgrade="${sdcard}/upgrade.img.gz"

if [ "$1" = "factorysettings" ]
then
	image_filename_upgrade="${sdcard}/factory_settings.img.gz"
fi

if [ ! -e ${sdcard}/tmp/ ]
then
       mkdir -p ${sdcard}/tmp/
fi

if [ ! -e /tmp/emmcboot ]
then
       mkdir -p /tmp/emmcboot
fi

umount ${sdcard} || true
mount ${sdcard_dev}p1 ${sdcard} -t vfat || true

NOW=$(date +"%m-%d-%Y %H:%M:%S")

unpack_resume_flag_up () {
	echo "Upgrade resume flag up!"
	echo "Upgrade started at: $NOW">>${sdcard}/unpack_resume_autorun.flag
}

#echo "Unpacking eMMC image.."

#if [ ! -e ${sdcard}/tmp/ ]
#then
#       mkdir -p ${sdcard}/tmp/
#fi

if [ ! -e  $image_filename_upgrade ]
then
	echo "Image not found: $image_filename_upgrade.. exit!"
#	rm ${sdcard}/unpack_resume_autorun.flag
	if [ -e ${sdcard}/unpack_resume_autorun.flag ]
	then
		rm ${sdcard}/unpack_resume_autorun.flag || true
	fi

	echo default-on > /sys/class/leds/beaglebone\:green\:usr0/trigger
	echo default-on > /sys/class/leds/beaglebone\:green\:usr1/trigger

	exit 0
fi

#echo "Run with $1 $2"

stage=0
counter_file=${sdcard}/unpack_stage.ini

incriment_stage_counter () {
	# Incriment and display restart counter
	counter_old=0
	counter_old=$(cat ${counter_file})
	if [ -z $counter_old ]
	then
		counter_old=0
	fi
	echo "Old counter: $counter_old"

	stage=$((counter_old+1))
	echo $stage > $counter_file
	echo "Unpacking stage: $stage"
}

reset_stage_counter () {
	echo "Resetting stage counter."
	echo 1 > ${sdcard}/unpack_stage.ini
	stage=1
	echo "Unpacking stage: $stage"
}

if [ $# -eq 2 ] && [ $2 -eq 2 ]
then
	reset_stage_counter
else
	stage=$(cat ${counter_file})
	if [ -z $stage ]
	then
		stage=0
	fi
	echo "Unpacking stage: $stage"
fi

if [ $stage -lt 2 ]
then
	reset_stage_counter 
	incriment_stage_counter
fi

write_pt_image
if [ $stage -le 2 ]
then
	echo Partition table wrote.
	incriment_stage_counter
	#reboot needs to set sdcard only
fi

set_sdcard_uEnv () {
	echo copying coupling uEng.txt
	mount ${eMMC}p1 /tmp/emmcboot -t vfat || true
	cp /sdcard/uEnv.txt /tmp/emmcboot/
	sh /sdcard/replace_uEnv.txt.sh /tmp/emmcboot || true
	uEnvPath=/tmp/emmcboot

	cp ${uEnvPath}/uEnv.txt ${uEnvPath}/uEnv.org.txt
	cp ${uEnvPath}/uEnv.sdcard.txt ${uEnvPath}/uEnv.txt

	sync
	sleep 5
	umount /tmp/emmcboot || true
}

update_uenv () {
	echo copying coupling uEng.txt
	mount ${eMMC}p1 /tmp/emmcboot -t vfat || true
	cp /sdcard/uEnv.txt /tmp/emmcboot/
	sh /sdcard/replace_uEnv.txt.sh /tmp/emmcboot || true
	sync
	sleep 5
	umount /tmp/emmcboot || true
}

if [ -e $image_filename_boot ]
then
	# needs to add a uEnv to swtich things to sdcard
	echo "Freeup boot during the backup process"
	mkfs.vfat ${eMMC}p1 -n boot
	incriment_stage_counter
fi

if [ "$1" = "factorysettings" ]
then
       	write_data_image
	incriment_stage_counter	
fi

	write_rootfs_image
	incriment_stage_counter	

        write_boot_image
	incriment_stage_counter	
	update_uenv
	incriment_stage_counter

update_uenv
incriment_stage_counter

echo "Finished.. byebye!"
echo "Upgrade resume flag down!"

if [ -e ${sdcard}/unpack_resume_autorun.flag ]
then
	rm ${sdcard}/unpack_resume_autorun.flag || true
fi

sync

echo default-on > /sys/class/leds/beaglebone\:green\:usr0/trigger

upgrade_autorun_flag_up () {
	echo "Autorun scripts after boot.. requested on $NOW" > ${sdcard}/upgrade_autorun.flag
}

upgrade_autorun_flag_down () {
	if [ -e ${sdcard}/upgrade_autorun.flag ] 
	then
		rm ${sdcard}/upgrade_autorun.flag || true
	fi
}

exit 0

if [ $# -eq 0 ]
then
	upgrade_autorun_flag_down
	reboot
fi

if [ "$1" != "factorysettings" ]
then
	upgrade_autorun_flag_down
fi

exit 0
