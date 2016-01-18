#!/bin/sh

id | grep -q root
is_root=$?

if [ ! $is_root ]
then
	echo "must be run as root"
	exit
fi

if [ -e /dev/mmcblk0p4 ]
then
        eMMC=/dev/mmcblk0
	sdcard_dev=/dev/mmcblk1
elif [ -e /dev/mmcblk1p4 ]
then
       	eMMC=/dev/mmcblk1
	sdcard_dev=/dev/mmcblk0
else
       	echo "4 partitions eMMC not found!"
	echo default-on > /sys/class/leds/beaglebone\:green\:usr1/trigger

	eMMC=/dev/mmcblk1
        sdcard_dev=/dev/mmcblk0
fi

if [ ! -e /sdcard/p1 ]
then
	mkdir -p /sdcard/p1
fi

if [ ! -e /tmp/emmcboot ]
then
	mkdir -p /tmp/emmcboot
fi

sdcard_p1="/sdcard/p1"
sdcard_p2="/sdcard/p2"

	if [ ! -e ${sdcard_p1} ]
	then
	       mkdir -p ${sdcard_p1}
	fi

	if [ ! -e ${sdcard_p2} ]
	then
	       mkdir -p ${sdcard_p2}
	fi

mount ${sdcard_dev}p1 ${sdcard_p1} -t vfat || true
mount ${sdcard_dev}p2 ${sdcard_p2} -t ext4 || true

rebootx () {
	#try to call rebootx from the upgrade partition first.
	if [ ! -e ${sdcard_p2}/scripts/rebootx.sh ]
        then
                mount ${sdcard_dev}p2 ${sdcard_p2} || true
        fi
        if [ -e ${sdcard_p2}/scripts/rebootx.sh ]
        then
                sh ${sdcard_p2}/scripts/rebootx.sh 120
                umount ${sdcard_p2}
                exit 0
        fi

        if [ ! -e ${sdcard_p1}/scripts/rebootx.sh ]
        then
		mount ${sdcard_dev}p1 ${sdcard_p1} -t vfat || true
	fi
	if [ -e ${sdcard_p1}/scripts/rebootx.sh ]
	then
		sh ${sdcard_p1}/scripts/rebootx.sh 120
		umount ${sdcard_p1} || true
		exit 0
	fi

	echo "rebootx is not accessible"
	reboot
}

flush_cache () {
	sync
}

flush_cache_mounted () {
	sync
#	blockdev --flushbufs ${eMMC} || true
}

alldone () {
	if [ -e /sys/class/leds/beaglebone\:green\:usr0/trigger ] ; then
		echo default-on > /sys/class/leds/beaglebone\:green\:usr0/trigger
		echo default-on > /sys/class/leds/beaglebone\:green\:usr1/trigger
		echo default-on > /sys/class/leds/beaglebone\:green\:usr2/trigger
		echo default-on > /sys/class/leds/beaglebone\:green\:usr3/trigger
	fi

	echo "Done!"

	echo "Rebooting..."
	sync

	rebootx
}

flush_cache () {
	sync
}

write_pt_image () {
	echo "Writing partition table image!"

	image_filename_prfx="upgrade"
	image_filename_rootfs="$image_filename_prfx-rootfs.img.gz" 
	image_filename_data="$image_filename_prfx-data.img.gz"
	image_filename_boot="$image_filename_prfx-boot.img.gz"
	image_filename_pt="$image_filename_prfx-pt.img.gz"

#	image_filename_upgrade="${sdcard_p2}/upgrade.img.gz"

#	if [ "$1" = "factorysettings" ]
#	then
	image_filename_upgrade="${sdcard_p1}/factory_settings.img.gz"
#	fi

	echo timer > /sys/class/leds/beaglebone\:green\:usr0/trigger
        tar xOf $image_filename_upgrade $image_filename_pt | gunzip -c | dd of=${eMMC} bs=16M
	flush_cache_mounted
	echo default-on > /sys/class/leds/beaglebone\:green\:usr0/trigger
	echo "Done writing partition table image!"
}

repartition_drive () {
	dd if=/dev/zero of=${eMMC} bs=1M count=16
	flush_cache

	echo "Repartitioning eMMC!"

	write_pt_image
	flush_cache
	flush_cache_mounted

	echo "Partitioned!"
}

partition_drive () {
	flush_cache

	echo "Unmounting!"
	umount ${eMMC}p1 > /dev/null || true
	umount ${eMMC}p2 > /dev/null || true
	umount ${eMMC}p3 > /dev/null || true
	umount ${eMMC}p4 > /dev/null || true

	flush_cache
	repartition_drive
	flush_cache
}

update_uenv () {
	echo copying coupling uEng.txt
	if [ ! -e /tmp/emmcboot ]
	then
	      mkdir -p /tmp/emmcboot
	fi
	mount ${eMMC}p1 /tmp/emmcboot -t vfat || true
	cp /sdcard/p1/uEnv.txt /tmp/emmcboot/
	sh /sdcard/p1/scripts/replace_uEnv.txt.sh /tmp/emmcboot || true
	sync
	sleep 5
	umount /tmp/emmcboot || true
}

reset_uenv () {
	echo "resetting uEnv!"
	cp ${sdcard_p1}/uEnv.72check.txt ${sdcard_p1}/uEnv.txt

	if [ ! -e /tmp/emmcboot ]
	then
	        mkdir -p /tmp/emmcboot
	fi

        mount ${eMMC}p1 /tmp/emmcboot -t vfat

	cp /tmp/emmcboot/uEnv.72check.txt /tmp/emmcboot/uEnv.txt
	sync
#exit
 	umount /tmp/emmcboot
	rm -r /tmp/emmcboot || true
        echo "Done returning to gpio 72 check version"
}

stop_packing_restarting ()
{
	reset_uenv
	if [ -e ${sdcard_p1}/pack_resume_autorun.flag ]
	then
        	rm ${sdcard_p1}/pack_resume_autorun.flag || true
	fi

	if [ -e ${sdcard_p1}/unpack_resume_autorun.flag ]
	then
        	rm ${sdcard_p1}/unpack_resume_autorun.flag || true
	fi
}

incriment_restart_counter () {
	# Incriment and display restart counter
	counter_file=${sdcard_p1}/restart_counter.ini
	counter_old=$(cat ${counter_file})
	counter=$((counter_old+1))
	echo $counter > $counter_file
	echo "Restart counter: $counter"
}

counter=2

if [ -e ${sdcard_p1}/unpack_resume_autorun.flag ]
then
        echo "Resume eMMC unpacking flag found up"
        incriment_restart_counter

        if [ "$counter" -ge 7 ]
        then
                echo Restart counter exceeded 7.. quitting upgrade operation
                stop_packing_restarting
                echo Rebooting
#                exit 0
                rebootx
        fi

        echo "Resuming eMMC unpacking"
 	sh ${sdcard_p1}/scripts/unpack_latest_version.sh noreboot $counter || true
        result=$?
        if [ $result -eq 1 ]
        then
                echo Error unpacking eMMC, restarting...
#               exit 0
                rebootx
        fi

        update_uenv
        stop_packing_restarting
        alldone
        exit
fi

if [ ! -e ${eMMC}p4 ]
then
        echo "Partitioning $eMMC"
	partition_drive
	sync
	if [ -e ${eMMC}p4 ]
	then
		echo "Done partitioning $eMMC!"
	else
		echo "Cannot update partition table at  $eMMC! restarting!"
		echo "Write Perm Partition" > ${sdcard_p1}/write_perm_partition.flag

		sync
		rebootx
		exit
	fi
else
	echo "Device is partitioned"
fi

echo "Restoring system from sdcard at $sdcard_dev to eMMC at $eMMC!"
sh ${sdcard_p1}/scripts/unpack_latest_version.sh factorysettings $counter || true

if [ -e "${eMMC}p4" ]
then
        echo "Perminant data partition found! bypassing repartitioning!"
else
	echo "Repartitioning needed!"
        alldone
	exit
fi

update_uenv

if [ -e ${sdcard_p1}/write_perm_partition.flag ]
then
	echo "eMMC Flasher: writing to /perm partition (to format)"
	if [ -e ${sdcard_p2}/upgrade.img.gz ]
	then
		# todo check mkfs.ext4
		rm ${sdcard_p1}/write_perm_partition.flag || true
		mkdir -p /tmp/perm
		mount ${eMMC}p4 /tmp/perm -t ext4
		rm -r /tmp/perm/* || true
		echo "Done formatting /perm partition"
		umount /tmp/perm/
		echo "Done formatting /perm partition"
	fi
fi

echo "eMMC Flasher: all done!"
sync

sleep 5

umount ${sdcard_p1} > /dev/null || true
umount ${sdcard_p2} > /dev/null || true

alldone

rebootx
