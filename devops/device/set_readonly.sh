#!/bin/bash

#exit 0

if   [ -e /dev/mmcblk1p3 ]
then
        echo /data parition found
        mmcblk="/dev/mmcblk1"
elif [ -e /dev/mmcblk0p3 ]
then
        echo /data parition found
        mmcblk="/dev/mmcblk0"
else
        echo /data parition not found
        exit 1
fi

echo remove uneeded pacages
mount -o remount,rw /
mount -o remount,rw /boot/uboot/

apt-get -y remove --purge wolfram-engine triggerhappy anacron logrotate dbus dphys-swapfile xserver-common lightdm

apt-get -y update
#apt-get -y upgrade

echo install round log
apt-get -y install busybox-syslogd
dpkg --purge rsyslog

echo mounting /data partition ...
mkdir -p /tmp/mmcblk
mount ${mmcblk}p3 /tmp/mmcblk

echo find UUIDs
UUID_p2=$(blkid ${mmcblk}p2 | awk -FUUID=\" '{print $2}' | awk -F\" '{print $1}')
UUID_p1=$(blkid ${mmcblk}p1 | awk -FUUID=\" '{print $2}' | awk -F\" '{print $1}')
UUID_p3=$(blkid ${mmcblk}p3 | awk -FUUID=\" '{print $2}' | awk -F\" '{print $1}')
UUID_p4=$(blkid ${mmcblk}p4 | awk -FUUID=\" '{print $2}' | awk -F\" '{print $1}')
EMMC=${mmcblk}p2
if [ -z $UUID_p2 ]
then
        echo "/dev/mmcblk1 is not a valid block device"
#        UUID=$(lsblk -no UUID /dev/mmcblk0p2)
#        UUID_p3=$(blkid /dev/mmcblk0p3 | awk -FUUID=\" '{print $2}' | awk -F\" '{print $1}')
#        UUID_p4=$(blkid /dev/mmcblk0p4 | awk -FUUID=\" '{print $2}' | awk -F\" '{print $1}')
#        EMMC=/dev/mmcblk1p2
#        if [ -z $UUID ]
#        then
                echo "Cann't find a booting root!"
                exit 0
#        fi
fi

echo "Root fs Block device found at $UUID_p2"


if [ -z $UUID_p3 ]
then
        echo "Cann't find UUID for /data partition!"
        exit 0
fi

if [ -z $UUID_p4 ]
then
        echo "Cann't find UUID for /perm partition!"
        exit 0
fi

echo "/boot/uboot partition found at $UUID_p1"
echo "/ partition found at $UUID_p2"

echo "/data partition found at $UUID_p3"
echo "/perm partition found at $UUID_p4"


mount | grep /var
result=$?
if [ $result -eq 1 ]
then
	echo move variable folders for the first time
	rm -r /var/log
	mv /var/* /tmp/mmcblk
	mount UUID=$UUID_p3 /var 
fi

echo Updating fstab..
echo "Adding automount for /data, /perm, /var and /var/log"
rootfs="/tmp/emmcrootfs"
if [ ! -e $rootfs ]
then
        mkdir -p $rootfs
fi

mount $EMMC $rootfs
fstab="$rootfs/etc/fstab"
fstab_new="${fstab}_new"
if [ -e $fstab_new ]
then
        rm $fstab_new
fi

while IFS= read -r var
do
        if test "${var#*/perm}" != "$var" #[[ "$var" == *perm* ]]
        then
                echo "Removing perm line from fstab..."
                continue
        fi
        if test "${var#*/data}" != "$var" #[[ "$var" == *"data"* ]]
        then
                echo "Removing data line from fstab..."
                continue
        fi

        if test "${var#*/var}" != "$var" #[[ "$var" == *"var"* ]]
        then
                echo "Removing var line from fstab..."
                continue
        fi
        if test "${var#*/boot}" != "$var" #[[ "$var" == *boot* ]]
        then
                echo "Removing boot line from fstab..."
                continue
        fi
        if test "${var#*p2}" != "$var" #[[ "$var" == *"p2"* ]]
        then
                echo "Removing rootfs line from fstab..."
                continue
        fi
        if test "${var#*/tmp}" != "$var" #[[ "$var" == *"tmp"* ]]
        then
                echo "Removing /tmp line from fstab..."
                continue
        fi
        if test "${var#*UUID=}" != "$var" #[[ "$var" == *"UUID"* ]]
        then
                echo "Removing UUID line from fstab..."
                continue
        fi

        echo "$var"
        echo $var >> $fstab_new

done < "$fstab"

readonly=1
if [[ $1 == "off" ]]
then
	echo "Readonly off"
	readonly=0
	echo "UUID=$UUID_p1  /boot/uboot   auto rw,defaults 0 0" >> $fstab_new
	echo "UUID=$UUID_p2  /   ext4    rw,noatime,errors=remount-ro  0  1" >> $fstab_new
else
	echo "Readonly ON"
	echo "UUID=$UUID_p1  /boot/uboot   auto ro,defaults 0 0" >> $fstab_new
	echo "UUID=$UUID_p2  /   ext4    ro,noatime,errors=remount-ro  0  1" >> $fstab_new
fi

echo "UUID=$UUID_p3  /data   ext4    rw,auto,user,errors=remount-ro  0  0" >> $fstab_new
echo "UUID=$UUID_p4  /perm   ext4    rw,auto,user,errors=remount-ro  0  0" >> $fstab_new

echo "UUID=$UUID_p3  /var    ext4    rw,auto,user,errors=remount-ro  0  0" >> $fstab_new

today=$(date "+%Y_%m_%d__%H_%M_%S")
echo backuped $fstab to $fstab$today.save

cp $fstab "${fstab}${today}.save"
cp $fstab_new $fstab

echo "Updated fstab: ${fstab_new}"
cat ${fstab_new}

sync

umount $rootfs || true
rm -r $rootfs || true
umount /tmp/mmcblk || true
rm -r /tmp/mmcblk || true

if [[ $1 == "off" ]]
then
	echo "Done with readonly off"
else
	mount -o remount,ro / > /dev/null
	mount -o remount,ro /boot/uboot/ > /dev/null
fi
echo done... please reboot!
