#!/bin/sh
mount -o rw -a /dev/sda1 /mnt
 
dd if=/dev/mmcblk0p2 of=/mnt/beagle_rootfs_backup.img bs=16M
sync
echo default-on > /sys/class/leds/beaglebone\:green\:usr0/trigger
