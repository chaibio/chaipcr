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

	cd $image_filename_upgrade_tar_temp_folder
	tar -xvf $image_filename_upgrade_temp

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

echo timer > /sys/class/leds/beaglebone\:green\:usr0/trigger

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

if [ "$1" = "factorysettings" ]
then
	image_filename_upgrade="${sdcard}/factory_settings.img.gz"
fi

if [ ! -e ${sdcard}/tmp/ ]
then
       mkdir -p ${sdcard}/tmp/
fi

umount ${sdcard} || true
mount ${sdcard_dev}p1 ${sdcard} -t vfat || true

NOW=$(date +"%m-%d-%Y %H:%M:%S")

unpack_resume_flag_up () {
	echo "Upgrade resume flag up!"
	echo "Upgrade started at: $NOW">>${sdcard}/unpack_resume_autorun.flag
}
echo "Unpacking eMMC image.."

if [ ! -e ${sdcard}/tmp/ ]
then
       mkdir -p ${sdcard}/tmp/
fi

if [ ! -e  $image_filename_upgrade ]
then
	echo "Image not found: $image_filename_upgrade.. exit!"
	rm ${sdcard}/unpack_resume_autorun.flag

	echo default-on > /sys/class/leds/beaglebone\:green\:usr0/trigger
	echo default-on > /sys/class/leds/beaglebone\:green\:usr1/trigger

	exit 0
fi

echo "Run with $1 $2"

stage=0
counter_file=${sdcard}/unpack_stage.ini

incriment_stage_counter () {
	# Incriment and display restart counter
	counter_old=$(cat ${counter_file})
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
	echo "Unpacking stage: $stage"
fi

if [ $stage -lt 2 -o  ! -e $image_filename_boot -o ! -e $image_filename_rootfs -o ! -e $image_filename_pt ]
then
	echo "Extracting image.."
	reset_stage_counter 
	extract_image_files
	incriment_stage_counter
fi

if [ -e $image_filename_pt ]
then
        write_pt_image
	rm $image_filename_pt
	if [ $stage -le 2 ]
	then
		echo Partition table wrote.
		incriment_stage_counter
		#reboot needs to set sdcard only
	fi
else
	echo "Partition table image not found!"
fi

set_sdcard_uEnv () {
	echo copying coupling uEng.txt
	mount ${eMMC}p1 /emmcboot -t vfat || true
	cp /sdcard/uEnv.txt /emmcboot/
	sh /sdcard/replace_uEnv.txt.sh /emmcboot || true
	uEnvPath=/emmcboot

	cp ${uEnvPath}/uEnv.txt ${uEnvPath}/uEnv.org.txt
	cp ${uEnvPath}/uEnv.sdcard.txt ${uEnvPath}/uEnv.txt

	sync
	sleep 5
	umount /emmcboot || true
}

update_uenv () {
	echo copying coupling uEng.txt
	mount ${eMMC}p1 /emmcboot -t vfat || true
	cp /sdcard/uEnv.txt /emmcboot/
	sh /sdcard/replace_uEnv.txt.sh /emmcboot || true
	sync
	sleep 5
	umount /emmcboot || true
}

if [ -e $image_filename_boot ]
then
	# needs to add a uEnv to swtich things to sdcard
	echo "Freeup boot during the backup process"
	mkfs.vfat ${eMMC}p1 -n boot
#	update_uenv
#	set_sdcard_uEnv
	incriment_stage_counter
fi

if [ "$1" = "factorysettings" ]
then
	if [ -e $image_filename_data ]
	then
        	write_data_image
	        rm $image_filename_data
		incriment_stage_counter	
	else
        	echo "Data image not found!"
	fi
fi

if [ -e $image_filename_rootfs ]
then
	write_rootfs_image
 	rm $image_filename_rootfs
	incriment_stage_counter	
else
        echo "Rootfs image not found: $image_filename_rootfs"
fi

if [ -e $image_filename_boot ]
then
        write_boot_image
	rm $image_filename_boot
	incriment_stage_counter	
	update_uenv
	incriment_stage_counter
else
       	echo "Boot image not found: $image_filename_boot"
fi

update_uenv
incriment_stage_counter

echo "Finished.. byebye!"
echo "Upgrade resume flag down!"
rm ${sdcard}/unpack_resume_autorun.flag || true

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
