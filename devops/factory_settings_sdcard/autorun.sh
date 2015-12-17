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
	echo default-on > /sys/class/leds/beaglebone\:green\:usr1/trigger

	eMMC=/dev/mmcblk1
        sdcard_dev=/dev/mmcblk0p1
fi

sync

if [ ! -e /sdcard ]
then
	mkdir /sdcard
fi

if [ ! -e /tmp/emmcboot ]
then
	mkdir -p /tmp/emmcboot
fi

#umount /sdcard > /dev/null || true
mount $sdcard_dev /sdcard -t vfat || true

sdcard="/sdcard"

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

	reboot
}

flush_cache () {
	sync
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
	cp /sdcard/uEnv.txt /tmp/emmcboot/
	sh /sdcard/replace_uEnv.txt.sh /tmp/emmcboot || true
	sync
	sleep 5
	umount /tmp/emmcboot || true
}

reset_uenv () {
	echo "resetting uEnv!"
	cp ${sdcard}/uEnv.72check.txt ${sdcard}/uEnv.txt

	if [ ! -e /tmp/emmcboot ]
	then
	        mkdir -p /tmp/emmcboot
	fi

        mount ${eMMC}p1 /tmp/emmcboot -t vfat

	cp /tmp/emmcboot/uEnv.72check.txt /tmp/emmcboot/uEnv.txt
	sync
#exit
 	umount /tmp/emmcboot
	rm -r /tmp/emmcboot
        echo "Done returning to gpio 72 check version"
}

stop_packing_restarting ()
{
	reset_uenv
	if [ -e ${sdcard}/pack_resume_autorun.flag ]
	then
        	rm ${sdcard}/pack_resume_autorun.flag
	fi

	if [ -e ${sdcard}/unpack_resume_autorun.flag ]
	then
        	rm ${sdcard}/unpack_resume_autorun.flag
	fi
}

incriment_restart_counter () {
	# Incriment and display restart counter
	counter_file=${sdcard}/restart_counter.ini
	counter_old=$(cat ${counter_file})
	counter=$((counter_old+1))
	echo $counter > $counter_file
	echo "Restart counter: $counter"
}

counter=2

if [ -e ${sdcard}/unpack_resume_autorun.flag ]
then
        echo "Resume eMMC unpacking flag found up"
        incriment_restart_counter

        if [ "$counter" -ge 7 ]
        then
                echo Restart counter exceeded 7.. quitting upgrade operation
                stop_packing_restarting
                echo Rebooting
#                exit 0
                reboot
        fi

        echo "Resuming eMMC unpacking"
 	sh /sdcard/unpack_latest_version.sh noreboot $counter || true
        result=$?
        if [ $result -eq 1 ]
        then
                echo Error unpacking eMMC, restarting...
#                exit 0
                reboot
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
		echo Write Perm Partition > /sdcard/write_perm_partition.flag
		reboot
		exit
	fi
else
	echo "Device is partitioned"
fi

echo "Restoring system from sdcard at $sdcard_dev to eMMC at $eMMC!"
sh /sdcard/unpack_latest_version.sh factorysettings $counter || true

if [ -e "${eMMC}p4" ]
then
        echo "Perminant data partition found! bypassing repartitioning!"
else
	echo "Repartitioning needed!"
        alldone
	exit
fi

update_uenv

if [ -e ${sdcard}/write_perm_partition.flag ]
then
	echo "eMMC Flasher: writing to /perm partition (to format)"
	if [ -e ${sdcard}/upgrade.img.gz ]
	then
		rm ${sdcard}/write_perm_partition.flag
		mkdir -p /tmp/perm
		mount ${eMMC}p4 /tmp/perm -t ext4
		rm -r /tmp/perm/*
		echo "Done formatting /perm partition"
		umount /tmp/perm/
		echo "Done formatting /perm partition"
	fi
fi

echo "eMMC Flasher: all done!"
sync
sleep 5
umount /sdcard > /dev/null || true 

alldone

reboot
