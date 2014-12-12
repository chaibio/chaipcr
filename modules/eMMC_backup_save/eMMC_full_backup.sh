#!/bin/sh
mount -o rw -a /dev/sda1 /mnt
 
dd if=/dev/mmcblk0 of=/mnt/beagle_backup.img bs=16M
sync
echo default-on > /sys/class/leds/beaglebone\:green\:usr0/trigger

