
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
	exit 0
fi

if [ -e /dev/mmcblk0p3 ]
then
        eMMC=/dev/mmcblk0
	sdcard_dev=/dev/mmcblk1
elif [ -e /dev/mmcblk1p3 ]
then
       	eMMC=/dev/mmcblk1
	sdcard_dev=/dev/mmcblk0
else
       	echo "3 or 4 partitions eMMC not found!"
	[ -e /sys/class/leds/beaglebone\:green\:usr1/trigger ] && echo default-on > /sys/class/leds/beaglebone\:green\:usr1/trigger

	eMMC=/dev/mmcblk1
        sdcard_dev=/dev/mmcblk0
fi

if [ ! -e /sdcard/p1 ]
then
	mkdir -p /sdcard/p1
fi

sdcard_p1="/sdcard/p1"
sdcard_p2="/sdcard/p2"

eMMC_boot=${eMMC}p1
eMMC_root=${eMMC}p2
eMMC_data=${eMMC}p3
eMMC_perm=${eMMC}p4
emmc_boot_files=/tmp/emmcboot
three_partitions_emmc=false
three_partitions_image=false

set3PartitionsEMMC ()
{	eMMC_boot=
	eMMC_root=${eMMC}p1
	eMMC_data=${eMMC}p2
	eMMC_perm=${eMMC}p3
	emmc_boot_files=/tmp/rootfs/boot/
	three_partitions_emmc=true
}

if [ -e $eMMC_perm ]
then
	if [ ! -e $emmc_boot_files ]
	then
		mkdir -p $emmc_boot_files
	fi
else
	set3PartitionsEMMC
fi

migration_needed=false
factory_settings_script_version=0
version_file=/mnt/fs_version.inf
if [ -e ${version_file} ]
then
	factory_settings_script_version=$(cat ${version_file})
fi

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

boot_from_sdcard () {
        echo force booting from sdcard
        if [ -e /mnt/uEnv.sdcard.txt ] && [ -e /mnt/uEnv.txt ]
        then
                cp /mnt/uEnv.sdcard.txt /mnt/uEnv.txt
		sync
        fi
}

remove_upgrade_flags ()
{
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

counter=2
echo 1000 > /proc/sys/kernel/hung_task_timeout_secs
mount_sdcard_partitions

cat /proc/cmdline | grep s2pressed=1 > /dev/null
s2pressed=$?
if [ $s2pressed -eq 0 ]
then
        echo "Boot button pressed"
	remove_upgrade_flags
	boot_from_sdcard
else
        echo "Boot button not pressed"
fi

isUpgrade () {
	if [ $s2pressed -ne 0 ] && ( [ -e ${sdcard_p1}/unpack_resume_autorun.flag ] || [ -e ${sdcard_p2}/unpack_resume_autorun.flag ] )
	then
		return 0
	else
		return 1
	fi
}

rebootx () {
	echo "reboot"

	# try to call rebootx from the upgrade partition first.
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
	partprobe /dev/mmcblk1
}

alldone () {
	echo "Closing.. exit."
   	if [ -e ${sdcard_p2}/backup_perm.gz ]
    	then
		rm ${sdcard_p2}/backup_perm.gz
    	fi
    	if [ -e ${sdcard_p2}/backup_data.gz ]
    	then
		rm ${sdcard_p2}/backup_data.gz
    	fi
	umount ${sdcard_p1} > /dev/null || true
	umount ${sdcard_p2} > /dev/null || true

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

setLedTimer () {
	[ -e /sys/class/leds/beaglebone\:green\:usr0/trigger ] && echo timer > /sys/class/leds/beaglebone\:green\:usr0/trigger

}

setLedDefault () {
	[ -e /sys/class/leds/beaglebone\:green\:usr0/trigger ] && echo default-on > /sys/class/leds/beaglebone\:green\:usr0/trigger

}

write_pt_image () {
	echo "Writing partition table image!"

	image_filename_prfx="upgrade"
	image_filename_rootfs="$image_filename_prfx-rootfs.img.gz"
	image_filename_data="$image_filename_prfx-data.img.gz"
	image_filename_pt="$image_filename_prfx-pt.img.gz"
	image_filename_boot="$image_filename_prfx-boot.img.gz"

	image_filename_upgrade="${sdcard_p1}/factory_settings.img.tar"
	if isUpgrade
	then
		image_filename_upgrade="${sdcard_p2}/upgrade.img.tar"
	fi

	setLedTimer        
	tar xOf $image_filename_upgrade $image_filename_pt | gunzip -c | dd of=${eMMC} bs=16M
	flush_cache_mounted

	if $three_partitions_image
	then
		echo writing hidden boot binaries.
	        tar xOf $image_filename_upgrade $image_filename_boot | gunzip -c | dd of=${eMMC} bs=16M
	fi

	setLedDefault
	echo "Done writing partition table image!"
}

repartition_drive () {
	dd if=/dev/zero of=${eMMC} bs=1M count=16
	flush_cache

	echo "Repartitioning eMMC!"

	write_pt_image
	flush_cache
	flush_cache_mounted

	if $three_partitions_image
	then
		echo Partitioned to 3 partitions eMMC
		set3PartitionsEMMC
	fi
	echo "Partitioned!"
}

format_perm () {
       echo "Writing partition table image!"

        image_filename_prfx="upgrade"
        image_filename_rootfs="$image_filename_prfx-rootfs.img.gz"
        image_filename_perm="$image_filename_prfx-perm.img.gz"
        image_filename_pt="$image_filename_prfx-pt.img.gz"

        image_filename_upgrade="${sdcard_p1}/factory_settings.img.tar"
	if isUpgrade
	then
		image_filename_upgrade="${sdcard_p2}/upgrade.img.tar"
	fi

       setLedTimer
        tar xOf $image_filename_upgrade $image_filename_perm | gunzip -c | dd of=${eMMC_perm} bs=16M

        flush_cache_mounted
       	setLedDefault
        echo "Done writing empty /perm partition!"
}

format_data () {
        echo "Writing data partition formatting image!"
       setLedTimer
        
	tar xOf $image_filename_upgrade format-data.img.gz | gunzip -c | dd of=${eMMC_data} bs=16M
        flush_cache_mounted
       	setLedDefault
        echo "Done writing data partition formatting image!"
}

write_data_fs_image () {
        echo "Writing data partition image!"
	image_filename_prfx="upgrade"
	image_filename_data="$image_filename_prfx-data.img.gz"
	image_filename_fs="${sdcard_p1}/factory_settings.img.tar"

       setLedTimer
        tar xOf $image_filename_fs $image_filename_data | gunzip -c | dd of=${eMMC_data} bs=16M
	flush_cache_mounted
       	setLedDefault
        echo "Done writing data partition image!"
}
	
partition_drive () {
	flush_cache

	echo "Unmounting!"
        if [ -e ${eMMC_boot} ] && ! $three_partitions_emmc
	then
		umount ${eMMC_boot} > /dev/null 2>&1 || true
	fi

	umount ${eMMC_root} > /dev/null 2>&1 || true
	umount ${eMMC_data} > /dev/null 2>&1 || true
	umount ${eMMC_perm} > /dev/null 2>&1 || true

	flush_cache
	repartition_drive
	flush_cache
}

reset_s2 () {
	if [ $s2pressed -eq 0 ]
	then
        	echo "Boot button found pressed"
	else
        	echo "Boot button is not pressed"
		return
	fi

	echo "Resetting s2 button!"
	echo 72 > /sys/class/gpio/export
	cat /sys/class/gpio/gpio72/value
	echo out > /sys/class/gpio/gpio72/direction
	echo 0 > /sys/class/gpio/gpio72/value
	cat /sys/class/gpio/gpio72/value	
	echo 72 > /sys/class/gpio/unexport
}

update_uenv () {
        if [ ! -e /tmp/emmcboot ]                                                
        then                                                                     
              mkdir -p /tmp/emmcboot                                             
        fi

	echo resetting to boot switch dependant uEnv                       
        cp /mnt/uEnv.72check.txt /mnt/uEnv.txt || true                
        cp /sdcard/p1/uEnv.72check.txt /sdcard/p1/uEnv.txt || true                

	# first param =2 in case of upgrade.. =1 for factory settings.                               
        if $three_partitions_image
        then
		echo Dealing with uEnv.txt on three partitions system.
		if [ ! -e /tmp/rootfs ] 
		then
			mkdir -p /tmp/rootfs || true
		fi
		mount | grep ${eMMC_root}
		if [ $? -eq 0 ]
		then
			echo ${eMMC_root} is mounted already
		else
			if mount ${eMMC_root} /tmp/rootfs
			then
				echo Error in mounting rootfs. Failed to switch boot uEnv.
				return 1
			fi
		fi
		echo running factory settings version of replace_uEnv.txt.sh
#       	        sh /sdcard/p1/scripts/replace_uEnv.txt.sh $emmc_boot_files || true
		echo resetting to boot switch dependant uEnv
	        cp $emmc_boot_files/uEnv.72check.txt $emmc_boot_files/uEnv.txt || true
        	sync
	        sleep 5
        	umount /tmp/rootfs || true
	else
		echo Dealing with four partitions system.
	        echo copying coupling uEng.txt
		mount ${eMMC_boot} $emmc_boot_files -t vfat || true

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
		if mount | grep $emmc_boot_files
		then
	        	umount $emmc_boot_files || true
			rm -r $emmc_boot_files || true
		fi
        fi

        sync
        sleep 5
}

backup_network () {

	echo Backing up network files.

	if [ ! -e /tmp/rootfs ]
	then
		mkdir -p /tmp/rootfs || true
	fi

	mount | grep ${eMMC_root}
	if [ $? -eq 0 ]
	then
		echo ${eMMC_root} is mounted already
	else
		if mount ${eMMC_root} /tmp/rootfs
		then
			echo "eMMC rootfs mounted successfully."
		else
			echo Error in mounting rootfs. Failed to backup network files.
			return 1
		fi
	fi

	if [ -e /tmp/rootfs/etc/network/interfaces ]
	then
	   cp /tmp/rootfs/etc/network/interfaces ${sdcard_p2}/
	   cp /tmp/rootfs/etc/network/interfaces ${sdcard_p2}/interfaces.last_upgrade
	fi
	if [ -e /tmp/rootfs/etc/dnsmasq.conf ]
	then
	   cp /tmp/rootfs/etc/dnsmasq.conf ${sdcard_p2}/
           cp /tmp/rootfs/etc/dnsmasq.conf ${sdcard_p2}/dnsmasq.conf.last_upgrade
	fi
	if [ -e /tmp/rootfs/etc/hostapd/hostapd.conf ]
	then
	   cp /tmp/rootfs/etc/hostapd/hostapd.conf ${sdcard_p2}/
           cp /tmp/rootfs/etc/hostapd/hostapd.conf ${sdcard_p2}/hostapd.conf.last_upgrade
	fi

	sync
        sleep 5
	umount /tmp/rootfs || true
        sync
        sleep 5
}

reset_uenv () {
	echo "resetting uEnv!"
        if [ -z $emmc_boot_files ]
	then
		if [ ! -e $emmc_boot_files ]
		then
		        mkdir -p $emmc_boot_files
		fi

		if mount | grep $emmc_boot_files || $three_partitions_emmc
		then
			echo $emmc_boot_files already mounted!
		else
		        mount ${eMMC_boot} $emmc_boot_files -t vfat || true
		fi
        fi

	cp ${sdcard_p1}/uEnv.72check.txt ${sdcard_p1}/uEnv.txt || true
        cp /mnt/uEnv.72check.txt /mnt/uEnv.txt || true

	cp $emmc_boot_files/uEnv.72check.txt $emmc_boot_files/uEnv.txt || true
	sync
	sleep 5

        if $three_partitions_emmc
        then
		umount /tmp/rootfs || true
	else
		if mount | grep $emmc_boot_files
		then
	        	umount $emmc_boot_files || true
			rm -r $emmc_boot_files || true
		fi
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

        file1=$emmc_boot_files/uEnv.txt
        file2=$emmc_boot_files/uEnv.72check.txt

        if [ ! -e $emmc_boot_files ]
        then
              mkdir -p $emmc_boot_files
        fi
	sync

	if mount | grep $emmc_boot_files || $three_partitions_emmc
	then
		echo $emmc_boot_files already mounted!
	else
	        mount ${eMMC_boot} $emmc_boot_files -t vfat || true
	fi

	files_verification $1
	if mount | grep $emmc_boot_files
	then
	        umount $emmc_boot_files || true
		rm -r $emmc_boot_files || true
	fi
}

increment_restart_counter () {
	# Increment and display restart counter
	counter_file=${sdcard_p2}/restart_counter.ini
	counter_old=$(cat ${counter_file})
	counter=$((counter_old+1))
	echo $counter > $counter_file
	echo "Restart counter: $counter"
}

perform_data_restore () {
	echo Checking for backuped partitions
        if [ -e ${sdcard_p2}/backup_perm.gz ]
        then
        	echo Backup found from a previous run. Restoring...
		mkdir -p /tmp/p4 || true
                if mount ${eMMC_perm} /tmp/p4
                then
                	echo Restoring /perm partition contents.
                        tar xfv ${sdcard_p2}/backup_perm.gz -C /tmp/p4/
                        umount /tmp/p4
                else
               		echo Error mounting /perm partition to restore.
                fi
                sync
	else
        	echo No /perm contents backup found.
	fi

        if [ -e ${sdcard_p2}/backup_data.gz ]
        then
        	echo Backup found for /data partition. Restoring...
		mkdir -p /tmp/p3 || true
                if mount ${eMMC_data} /tmp/p3
                then
                	echo Restoring /perm partition contents.
			cd /tmp/p3
			rm -r * || true
			cd ~
                        tar xfv ${sdcard_p2}/backup_data.gz -C /tmp/p3/
			sync
                        umount /tmp/p3
		else
                	echo Error mounting /data partition to restore.
		fi
                sync
       	else
       		echo No /data backup found.
	fi
}

backup_data () {
    	if [ -e ${sdcard_p2}/backup_data.gz ]
        then
                echo Backup found from a previous run.
        else
                mkdir -p /tmp/p3 || true
                if mount ${eMMC_data} /tmp/p3
                then
                        echo Saving /data partition contents.
                        cd /tmp/p3
                        tar cfv ${sdcard_p2}/backup_data.gz *
                        sync
                        cd ~
                        umount /tmp/p3 || true
                else
                        echo Error mounting /data parition.
                fi
	fi
}

backup_perm () {
    	if [ -e ${sdcard_p2}/backup_perm.gz ]
        then
                echo /perm backup found from a previous run.
        else
                mkdir -p /tmp/p4 || true
                if mount ${eMMC_perm} /tmp/p4
                then
                        echo Saving /perm partition contents.
                        cd /tmp/p4
                        tar cfv ${sdcard_p2}/backup_perm.gz *
                        sync
                        cd ~
                        umount /tmp/p4 || true
                else
                        echo Error mounting /perm parition.

                fi
        fi
}

perform_upgrade () {
        echo "Resume eMMC unpacking flag found up"
        increment_restart_counter

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
	perform_data_restore

	reset_update_uenv_with_verification 2
       	remove_upgrade_flags
	reset_uenv
        alldone
        exit 0
}

isValidPermGeometry () {
	echo "Testing ${eMMC_perm} validaty"
	if [ ! -e ${eMMC_perm} ]
	then
		echo Device not partitioned up to 5 partitions.
		return 1
	fi
	result=1

	start=$(hdparm -g ${eMMC_perm} | awk -F 'start =' '{print $2}')
	if [ -z $start ]
	then
		echo No valid geometry found.
		return 1
	fi

        echo partition starts at $start
        # allowing old factory settings images partitioning with or without format
        if isUpgrade
        then
               echo Checking geometery for an upgrade case.
        else
               echo Checking geometery for a factory settings case.

               fs_date=$( date +%Y%m%d -r ${sdcard_p1}/factory_settings.img.tar)
               echo "Factory settings image date: $fs_date"
               # factory settings file is older than 3-3-2017
                if [ $fs_date -lt 20170303 ]
                then
                        echo Old factory settings image found.

                        if [ $start -eq 7649280 ]
                        then
                                echo "Old partition geometery found with an old factory settings image"
                                result=0

                                return 0
                        else
                                echo Old factory settings image with incompatible geometery. Partitioning needed.
                                result=1

                                return 1
                        fi
                else
                        echo New factory settings image found. Must burn to the small eMMC size only.
                fi
        fi

        if [ $start -eq 7452672 ]
        then
                echo "Partition geometery is compatible."
                result=0
        else
                result=1
        fi

	return $result
}

isValidDataGeometry () {
	echo "Testing ${eMMC_data} validaty"
	if [ ! -e ${eMMC_data} ]
	then
		echo Device is not partitioned up to 4 partitions.
		return 1
	fi
	result=1

	start=$(hdparm -g ${eMMC_data} | awk -F 'start =' '{print $2}')
	if [ -z $start ]
	then
		echo No valid data partition geometry found.
		return 1
	fi

        echo data partition starts at $start
        # allowing old factory settings images partitioning with or without format
        if isUpgrade
        then
               echo Checking /data geometery for an upgrade case.
        else
               echo Checking /data geometery for a factory settings case.

               fs_date=$( date +%Y%m%d -r ${sdcard_p1}/factory_settings.img.tar)
               echo "Factory settings image date: $fs_date"
               # factory settings file is older than 3-3-2017
                if [ $fs_date -lt 20170303 ]
                then
                        echo Old factory settings image found.

                        if [ $start -eq 6600704 ]
                        then
                                echo "Old partition geometery found with an old factory settings image"
                                result=0

                                return 0
                        else
                                echo Old factory settings image with incompatible geometery. Partitioning needed.
                                result=1

                                return 1
                        fi
                else
                        echo New factory settings image found. Must burn to the small eMMC size only.
                fi
        fi

        if [ $start -eq 6404096 ]
        then
                echo "Data partition geometery is compatible."
                result=0
        else
                result=1
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
	mount ${eMMC_perm} /tmp/permcheck
	if [ $? -eq 0 ]
	then
		echo "${eMMC_perm} mounted!"
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

isValidDataPartition () {
	isValidDataGeometry
	if [ $? -eq 1 ]
	then
		echo "Invalid data partition geometery"
		return 1
	fi
        result=1

	if [ -e /tmp/data/.tmp/shadow.backup ] || [ -e /tmp/data/.tmp/dhclient.*.leases ]
	then
		result=0
	else
		echo factory settings data partition copying should format the partition.
	fi	

	mkdir /tmp/datacheck -p || true
	mount ${eMMC_data} /tmp/datacheck
	#mount /dev/mmcblk1p2 /tmp/datacheck
	if [ $? -eq 0 ]
	then
		echo "${eMMC_data} mounted!"
		echo "Test Test" >> /tmp/datacheck/write_test_data_partition.flag
		if [ -e /tmp/datacheck/write_test_data_partition.flag ]
		then
			rm /tmp/datacheck/write_test_data_partition.flag || true
			result=0
		fi
		umount /tmp/datacheck || true
	fi
	rm -r /tmp/datacheck || true

	return $result
}

if isUpgrade
then
	image_information=$(tar -xf /tmp/upgrade/upgrade.img.tar configuration.json --to-stdout)
else
	image_information=$(tar -xf ${sdcard_p1}/factory_settings.img.tar configuration.json --to-stdout)
fi

echo image information: $image_information

if [ $factory_settings_script_version -ge 120 ] && ! [ -z $image_information ]
then
	echo three partitions image on SDCard
	three_partitions_image=true
	if ! $three_partitions_emmc
	then
		echo four partitions image on eMMC.. migration needed.
		migration_needed=true
	fi
else
	echo four partitions image on sdcard
	if $three_partitions_emmc
	then
		echo Three partitions image on eMMC.. migration needed.
		migration_needed=true
	fi
fi

isValidPermPartition
isValidPermResult=$?

isValidDataPartition
isValidDataResult=$?

echo "Validity test for /perm and /data partitions: $isValidPermResult and $isValidDataResult"
if [ $isValidPermResult -eq 1 ] || [ $isValidDataResult -eq 1 ] || $migration_needed
then
	backup_perm
	if isUpgrade
	then
		backup_data
	fi

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
	        if isUpgrade 
        	then
	               format_data
		else
			write_data_fs_image			
	        fi
	else
		echo geometery still not valid for /perm partition.
	fi

	isValidDataGeometry
	isValidGeoResult=$?
	if [ $isValidGeoResult -eq 0 ]
	then
		echo Data partition geometery is now valid.. checking for the upgrade case..
	        if isUpgrade 
        	then
			echo upgrade case.. formating data partition.
	               	format_data
		else	
			write_data_fs_image
        	fi
	else
		echo geometery still not valid for /data partition.
	fi

	isValidPermPartition
	isValidPermResult=$?

	echo "Validity second test result: $isValidPermResult"
	if [ $isValidPermResult -eq 0 ]
	then
		echo "Done partitioning $eMMC!"
		perform_data_restore
	else
		echo "Cannot update partition table at  $eMMC_perm! restarting!"
		echo "Write Perm Partition 2" > ${sdcard_p2}/write_perm_partition.flag

		sync
		rebootx
		exit 0
	fi

	isValidDataPartition
	isValidDataResult=$?

	echo "Validity second test result: $isValidDataResult"
	if [ $isValidDataResult -eq 0 ]
	then
		echo "Done partitioning $eMMC!"
		perform_data_restore
	else
		if $three_partitions_image
		then
			echo Bypassing data partition check for 3 partitions image.
		else
			echo "Cannot update data partition table at  $eMMC_data !!"
			echo "Write Data Partition 2" > ${sdcard_p2}/write_data_partition.flag
			if isUpgrade
			then
				echo data partition formatting needed.
			else
				write_data_fs_image
			fi

			sync
			echo Restarting
			rebootx
			exit 0
		fi
	fi
else
	echo "Device is partitioned"
fi

if isUpgrade
then
	perform_upgrade
else
	echo "Performing factory settings recovery.."
fi

echo "Restoring system from sdcard at $sdcard_dev to eMMC at $eMMC!"
sh ${sdcard_p1}/scripts/unpack_latest_version.sh factorysettings $counter || true

if [ -e "${eMMC_perm}" ]
then
        echo "Permanent data partition found! Bypassing repartitioning!"
else
	echo "Repartitioning needed!"
        alldone
	exit
fi

if [ -e ${sdcard_p1}/write_perm_partition.flag ] || [ -e ${sdcard_p2}/write_perm_partition.flag ]
then
	echo "eMMC Flasher: writing to /perm partition to format"
	format_perm
	rm ${sdcard_p1}/write_perm_partition.flag > /dev/null 2>&1 || true
	rm ${sdcard_p2}/write_perm_partition.flag > /dev/null 2>&1 || true
	echo "Done formatting /perm partition"
fi

if [ -e ${sdcard_p1}/write_data_partition.flag ] || [ -e ${sdcard_p2}/write_data_partition.flag ]
then
	echo "eMMC Flasher: writing to /data partition to format"
	format_data
	rm ${sdcard_p1}/write_data_partition.flag > /dev/null 2>&1 || true
	rm ${sdcard_p2}/write_data_partition.flag > /dev/null 2>&1 || true
	echo "Done formatting /data partition"
fi

perform_data_restore
reset_update_uenv_with_verification 1
backup_network
remove_upgrade_flags
reset_uenv
reset_s2
echo "eMMC Flasher: all done!"
sync

sleep 5

alldone
rebootx

exit 0

