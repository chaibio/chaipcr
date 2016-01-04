
#!/bin/sh

#exit

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

if [ ! -e /emmcboot ]
then
	mkdir /emmcboot
fi

umount /sdcard > /dev/null || true
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

reset_uenv () {
	echo "resetting uEnv!"
	cp ${sdcard}/uEnv.72check.txt ${sdcard}/uEnv.txt

        mkdir -p /tmp/emmcboot
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

if [ -e ${sdcard}/pack_resume_autorun.flag ]
then
	echo "Resume eMMC packing flag found up"
	incriment_restart_counter

	if [ "$counter" -ge 5 ] 
	then
		echo Restart counter exceeded 4.. quitting packing operation
		stop_packing_restarting
		echo Rebooting
#		exit 0
		reboot
	fi

	echo "Resuming eMMC packing"

	sh /sdcard/pack_latest_version.sh || true
	result=$?
	if [ $result -eq 1 ]
	then
		echo Error packing eMMC, restarting...
#		exit 0
		reboot
	fi

	update_uenv
	stop_packing_restarting
	alldone
	exit
fi

#if [ ! -e ${sdcard}/factory_settings.img.gz ]
#then
	echo "Creating factory settings images! Copying from eMMC at $eMMC to sdcard at $sdcard_dev!"
	sh /sdcard/pack_latest_Version.sh || true
	sync
	echo Creating factory settings image done.. Now creating upgrade image. 	
	echo timer > /sys/class/leds/beaglebone\:green\:usr1/trigger
	alldone
	exit 0
#fi

echo "eMMC Grabber: all done!"
sync
sleep 5
umount /sdcard > /dev/null || true 

alldone

reboot

