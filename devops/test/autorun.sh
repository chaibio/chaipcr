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

debug=1
BASEDIR=$(dirname $0)

if [ $debug -eq 1 ]
then
	NOW=$(date +"%m-%d-%Y %H:%M:%S")
	log_file=/mnt/booting.log

	mkdir /tmp/upgrade -p
	if [ -e /dev/mmcblk0p3 ]
	then
        	eMMC=/dev/mmcblk0
		sdcard_dev=/dev/mmcblk1
		mount ${sdcard_dev}p2 /tmp/upgrade
		log_file=/tmp/upgrade/booting.log
	elif [ -e /dev/mmcblk1p3 ]
	then
       		eMMC=/dev/mmcblk1
		sdcard_dev=/dev/mmcblk0
		mount ${sdcard_dev}p2 /tmp/upgrade
		log_file=/tmp/upgrade/booting.log
	else
       		echo "4 partitions eMMC not found!"
	fi

	echo "Logging boot to: $log_file.. timestamp: $NOW"
	echo "==== New boot at: $NOW" >> $log_file
	echo "==== Checking if factory settings scripts should be upgraded" >> $log_file

	version_file=/mnt/fs_Version.inf
	version_current=0
	if [ -e ${version_file} ]
	then
		version_current=$(cat ${version_file})
	fi

	version_upgrade=$(tar -xf /tmp/upgrade/upgrade.img.tar factory-scripts/fs_version.inf --to-stdout)
	if [ -z $version_upgrade ]
	then
		version_upgrade=0
	fi
	echo current factory settings scripts version $version_current, upgrade image version is $version_upgrade
	echo current factory settings scripts version $version_current, upgrade image version is $version_upgrade  >> $log_file 2>&1
	if [ $version_current -lt $version_upgrade ]
	then
		echo upgrading factory settings scripts  >> $log_file 2>&1
		cd /mnt
		tar -xf /tmp/upgrade/upgrade.img.tar factory-scripts
		cp -r factory-scripts/* .
		sync
		rm -r factory-scripts
		echo done extracting.  >> $log_file 2>&1
	fi

	sh /mnt/autorun_core.sh  >> $log_file 2>&1
	result=$?
	echo "Boot with logging complete!"
	tail $log_file
else
	sh /mnt/autorun_core.sh
	result=$?
fi

keep_upgrading_experiment () {
	NOW=$(date +"%m_%d_%Y-%H_%M_%S")
	mkdir -p /tmp/sdcard_p1
	mkdir -p /tmp/rootfs
	sdcard_p1=/tmp/sdcard_p1
	mount /dev/mmcblk0p1 ${sdcard_p1}

	# Incriment and display expermiment reboot counter
	counter_file=${sdcard_p1}/experiment_restart_counter.ini
	if [ -e ${counter_file} ]
	then
		counter_old=$(cat ${counter_file})
	else
		counter_old=1
	fi
	counter=$((counter_old+1))

	echo $counter > $counter_file

	echo "Exprement restart counter: $counter"

	if [ "$counter" -ge 50 ]
        then
                echo Restart counter exceeded 50 times.. quitting experimental upgrade operation
                exit 0
	fi

	sync
	mount /dev/mmcblk1p2 /tmp/rootfs
	echo injecting code to next execution
	ls /tmp/rootfs

sed -i -- 's/exit 0/#exit 0/g' /tmp/rootfs/etc/rc.local
sync

cat >> /tmp/rootfs/etc/rc.local << EOL

do_exp () {

	echo product of the restart experiment# $counter.. at $NOW
	echo after reboot of the restart experiment# $counter.. at $NOW >> /sdcard/factory/booting.log

	if [ ! -e /tmp/sdcard_p1 ]
        then
                mkdir -p /tmp/sdcard_p1
        fi

        sdcard_p1=/tmp/sdcard_p1
        mount /dev/mmcblk0p1 ${sdcard_p1}

        # expermiment successful reboot counter
        counter_file=${sdcard_p1}/experiment_restart_counter.ini
	counter_old=$(cat ${counter_file})
	counter=counter_old
	echo "Exprement restart counter: $counter"

        if [ "$counter" -ge 50 ]
        then
                echo Restart counter exceeded 50 times.. quitting experimental upgrade operation
                exit 0
	fi
	ip=\$(ifconfig eth0 | grep "inet addr" | cut -d ':' -f 2 | cut -d ' ' -f 1)
	wget "http://beaglebone.info/report_exp.php?deviceid=LCDAug17&c=$counter&msg=OnImageofExp_$counter&ip=\$ip&ts=$NOW"
	result=$?
	echo reporting result is $result
	if [ $result -eq 1 ]
	then
		echo "failed reporting to web"
		exit 0
	fi
	systemctl stop realtime.service

	echo "Performing upgrade"
	sleep 600
     	ip=\$(ifconfig eth0 | grep "inet addr" | cut -d ':' -f 2 | cut -d ' ' -f 1)
	echo ip is \$ip
   	wget "http://beaglebone.info/report_exp.php?deviceid=LCDAug17&c=$counter&msg=WaitTimeout_About_to_IntilizeUpgradeExp_$counter&ip=\$ip&ts=$NOW"&
#	systemctl disable realtime.service
#	systemctl stop realtime.service
#	cd /sdcard/upgrade/
#	if cmp upgrade.img.tar.Aug14 upgrade.img.tar
#	then
#		echo image is the latest
#	else
#		echo image is different.. copying..
#		cp upgrade.img.tar.Aug14 upgrade.img.tar
#		sync
#	fi

	bash /sdcard/upgrade/scripts/perform_upgrade.sh
	wget "http://beaglebone.info/report_exp.php?deviceid=LCDAug17&c=$counter&msg=UpgradeIntilizedExp_$counter&ip=\$ip&ts=$NOW"
}

do_exp &
exit 0

EOL

	sync

	umount /tmp/rootfs
	umount ${sdcard_p1}
	echo exprimental code done
}

keep_upgrading_experiment

exit $result
