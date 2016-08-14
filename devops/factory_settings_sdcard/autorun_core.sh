#!/bin/sh
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

mount_sdcard_partitions () {
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
}

rebootx () {
	#try to call rebootx from the upgrade partition first.
	if [ ! -e ${sdcard_p2}/scripts/rebootx.sh ]
        then
                mount ${sdcard_dev}p2 ${sdcard_p2} || true
        fi
        if [ -e ${sdcard_p2}/scripts/rebootx.sh ]
        then
                sh ${sdcard_p2}/scripts/rebootx.sh 120
                umount ${sdcard_p2} || true
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
	exit 0
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
	exit 0
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

	image_filename_upgrade="${sdcard_p1}/factory_settings.img.tar"

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

format_perm () {
       echo "Writing partition table image!"

        image_filename_prfx="upgrade"
        image_filename_rootfs="$image_filename_prfx-rootfs.img.gz"
        image_filename_perm="$image_filename_prfx-perm.img.gz"
        image_filename_boot="$image_filename_prfx-boot.img.gz"
        image_filename_pt="$image_filename_prfx-pt.img.gz"

        image_filename_upgrade="${sdcard_p1}/factory_settings.img.tar"

        echo timer > /sys/class/leds/beaglebone\:green\:usr0/trigger
        tar xOf $image_filename_upgrade $image_filename_perm | gunzip -c | dd of=${eMMC}p4 bs=16M

        flush_cache_mounted
        echo default-on > /sys/class/leds/beaglebone\:green\:usr0/trigger
        echo "Done writing empty /perm partition!"
}

partition_drive () {
	flush_cache

	echo "Unmounting!"
	umount ${eMMC}p1 > /dev/null 2>&1 || true
	umount ${eMMC}p2 > /dev/null 2>&1 || true
	umount ${eMMC}p3 > /dev/null 2>&1 || true
	umount ${eMMC}p4 > /dev/null 2>&1 || true

	flush_cache
	repartition_drive
	flush_cache
}

update_uenv () {                                                        
# first param =2 in case of upgrade.. =1 for factory settings.                               
        echo resetting coupling uEng.txt
        if [ ! -e /tmp/emmcboot ]                                                
        then                                                                     
              mkdir -p /tmp/emmcboot                                             
        fi
	sync
	if mount | grep /tmp/emmcboot
	then
		echo /tmp/emmcboot already mounted!
	else
	        mount ${eMMC}p1 /tmp/emmcboot -t vfat || true                            
	fi
                           
	echo resetting to boot switch dependant uEnv                       
        cp /sdcard/p1/uEnv.txt /tmp/emmcboot/ || true                            
        cp /mnt/uEnv.72check.txt /mnt/uEnv.txt || true                
        cp /sdcard/p1/uEnv.72check.txt /sdcard/p1/uEnv.txt || true                
        cp /tmp/emmcboot/uEnv.72check.txt /tmp/emmcboot/uEnv.txt || true                            

        if [ $1 -eq 2 ]                                             
        then                                                                                     
                if [ -e /sdcard/p2/scripts/replace_uEnv.txt.sh ]
                then
			echo running upgrade version of replace_uEnv.txt.sh
                        sh /sdcard/p2/scripts/replace_uEnv.txt.sh /tmp/emmcboot || true
                else
			echo running factory settings version of replace_uEnv.txt.sh while performing upgrade.
                        sh /sdcard/p1/scripts/replace_uEnv.txt.sh /tmp/emmcboot || true
                fi                                                                     
        else                                                                           
		echo running factory settings version of replace_uEnv.txt.sh
                sh /sdcard/p1/scripts/replace_uEnv.txt.sh /tmp/emmcboot || true        
        fi                                                                             

        sync                                                                                     
        sleep 5                                                                                  
	if mount | grep /tmp/emmcboot
	then
	        umount /tmp/emmcboot || true                                                   
		rm -r /tmp/emmcboot || true
	fi
}                                                                                      

reset_uenv () {
	echo "resetting uEnv!"
	cp ${sdcard_p1}/uEnv.72check.txt ${sdcard_p1}/uEnv.txt || true
        cp /mnt/uEnv.72check.txt /mnt/uEnv.txt || true

	if [ ! -e /tmp/emmcboot ]
	then
	        mkdir -p /tmp/emmcboot
	fi

#        mount ${eMMC}p1 /tmp/emmcboot -t vfat || true
	if mount | grep /tmp/emmcboot
	then
		echo /tmp/emmcboot already mounted!
	else
	        mount ${eMMC}p1 /tmp/emmcboot -t vfat || true                            
	fi

	cp /tmp/emmcboot/uEnv.72check.txt /tmp/emmcboot/uEnv.txt || true
	sync
	sleep 5

	if mount | grep /tmp/emmcboot
	then
	        umount /tmp/emmcboot || true                                                   
		rm -r /tmp/emmcboot || true
	fi
	echo "Done returning to gpio 72 check version"
}

files_verification () {
	echo verifying $file1 and $file2

	for a in 1 2 3 4 5
	do
		echo Checking uEnv updated successfully.. check# $a of 5

		if cmp -s $file1 $file2
		then
			echo updating uEnv done.
			break
		fi
	
		sleep 10
		umount ${sdcard_p1} > /dev/null || true
		umount ${sdcard_p2} > /dev/null || true
		mount_sdcard_partitions
		update_uenv $1
	done
}

reset_update_uenv_with_verification () {
        echo updating and verifying uEnv
        update_uenv $1

        file1=/mnt/uEnv.txt
        file2=/mnt/uEnv.72check.txt
	files_verification $1

	file1=/sdcard/p1/uEnv.txt
	file2=/sdcard/p1/uEnv.72check.txt
	files_verification $1

        file1=/tmp/emmcboot/uEnv.txt
        file2=/tmp/emmcboot/uEnv.72check.txt

        if [ ! -e /tmp/emmcboot ]                                                
        then                                                                     
              mkdir -p /tmp/emmcboot                                             
        fi
	sync

	if mount | grep /tmp/emmcboot
	then
		echo /tmp/emmcboot already mounted!
	else
	        mount ${eMMC}p1 /tmp/emmcboot -t vfat || true                            
	fi

	files_verification $1

	if mount | grep /tmp/emmcboot
	then
	        umount /tmp/emmcboot || true                                                   
		rm -r /tmp/emmcboot || true
	fi
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

	if [ -e ${sdcard_p2}/pack_resume_autorun.flag ]
	then
        	rm ${sdcard_p2}/pack_resume_autorun.flag || true
	fi

	if [ -e ${sdcard_p2}/unpack_resume_autorun.flag ]
	then
        	rm ${sdcard_p2}/unpack_resume_autorun.flag || true
	fi
}

incriment_restart_counter () {
	# Incriment and display restart counter
	counter_file=${sdcard_p2}/restart_counter.ini
	counter_old=$(cat ${counter_file})
	counter=$((counter_old+1))
	echo $counter > $counter_file
	echo "Restart counter: $counter"
}

mount_sdcard_partitions

cat /proc/cmdline | grep s2pressed=1 > /dev/null
s2pressed=$?
if [ $s2pressed -eq 0 ]
then
        echo "Boot button pressed"
else
        echo "Boot button not pressed"
fi

counter=2
if [ $s2pressed -ne 0 ] && ( [ -e ${sdcard_p1}/unpack_resume_autorun.flag ] || [ -e ${sdcard_p2}/unpack_resume_autorun.flag ] )
then
        echo "Resume eMMC unpacking flag found up"
        incriment_restart_counter

# was limited to 7 trails only.. if [ "$counter" -ge 7 ]
	if false
        then
                echo Restart counter exceeded 7.. quitting upgrade operation
                stop_packing_restarting
                echo Rebooting
                rebootx
		exit 0
        fi

        echo "Resuming eMMC unpacking"

	if [ -e ${sdcard_p2}/scripts/unpack_latest_version.sh ]
	then
		sh ${sdcard_p2}/scripts/unpack_latest_version.sh noreboot $counter || true
	else
	 	sh ${sdcard_p1}/scripts/unpack_latest_version.sh noreboot $counter || true
	fi

        result=$?
        if [ $result -eq 1 ]
        then
                echo Error unpacking eMMC, restarting...
                rebootx
		exit 0
        fi

#        update_uenv 2
reset_update_uenv_with_verification 2 
       stop_packing_restarting
        alldone
        exit
else
	echo "Performing factory settings recovery.."
fi

isValidPermGeometry () {
	echo "Testing ${eMMC}p4 validaty"
	if [ ! -e ${eMMC}p4 ]
	then
		echo Device not partitioned up to 5 partitions.
		return 1
	fi
	result=1

	start=$(hdparm -g ${eMMC}p4 | awk -F 'start =' '{print $2}')
	if [ -z $start ]
	then
		echo No valid geometry found.
		return 1
	fi

	echo partition starts at $start
	if [ $start -eq 7649280 ]
	then
		echo "Partition geometery is compatible."
		result=0
	else
		echo "Partition geometery is not compatible."
		return 1

	fi

	return $result
}

isValidPermPartition () {
	isValidPermGeometry
	if [ $? -eq 1 ]
	then
		echo "Invalid partition geometery"
		return 1
	fi

	result=1
	mkdir /tmp/permcheck -p || true
	mount ${eMMC}p4 /tmp/permcheck
	if [ $? -eq 0 ]
	then
		echo "${eMMC}p4 mounted!"
		echo "Test Test" >> /tmp/permcheck/write_test_perm_partition.flag
		if [ -e /tmp/permcheck/write_test_perm_partition.flag ]
		then
			rm /tmp/permcheck/write_test_perm_partition.flag || true
			result=0
		fi
		umount /tmp/permcheck || true
	fi
	rm -r /tmp/permcheck || true

	return $result
}

isValidPermPartition
isValidPermResult=$?

echo "Validity test result: $isValidPermResult"
if [ $isValidPermResult -eq 1 ]
then
        echo "Partitioning $eMMC"
	partition_drive
	sync
	hdparm -z ${eMMC}

	isValidPermGeometry
	isValidGeoResult=$?
	if [ $isValidGeoResult -eq 0 ]
	then
		echo Partition geometery is now valid.. formatting...
		format_perm
	else
		echo geometery still not valid for /perm partition.
	fi

	isValidPermPartition
	isValidPermResult=$?

	echo "Validity second test result: $isValidPermResult"
	if [ $isValidPermResult -eq 0 ]
	then
		echo "Done partitioning $eMMC!"
	else
		echo "Cannot update partition table at  $eMMC! restarting!"
		echo "Write Perm Partition 2" > ${sdcard_p2}/write_perm_partition.flag

		sync
		rebootx
		exit 0
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

if [ -e ${sdcard_p1}/write_perm_partition.flag ] || [ -e ${sdcard_p2}/write_perm_partition.flag ]
then
	echo "eMMC Flasher: writing to /perm partition (to format)"
	format_perm
	rm ${sdcard_p1}/write_perm_partition.flag > /dev/null 2>&1 || true
	rm ${sdcard_p2}/write_perm_partition.flag > /dev/null 2>&1 || true
	echo "Done formatting /perm partition"
fi

#update_uenv 1
reset_update_uenv_with_verification 1

stop_packing_restarting
echo "eMMC Flasher: all done!"
sync

sleep 5

umount ${sdcard_p1} > /dev/null || true
umount ${sdcard_p2} > /dev/null || true

alldone

rebootx

exit 0
