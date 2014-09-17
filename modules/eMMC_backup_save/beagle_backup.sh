#!/bin/sh
mount -o rw -a /dev/mmcblk1p1 /mnt

echo timer > /sys/class/leds/beaglebone\:green\:usr0/trigger
dd if=/dev/mmcblk0 of=/mnt/beagle_backup.img bs=16M
sync
echo default-on > /sys/class/leds/beaglebone\:green\:usr0/trigger

