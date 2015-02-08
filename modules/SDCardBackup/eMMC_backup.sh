#!/bin/sh

echo timer > /sys/class/leds/beaglebone\:green\:usr0/trigger

dd if=/dev/mmcblk1 of=/mnt/beagle_backup.img bs=16M ## comment the line below if this line is uncommented
#dd if=/mnt/beagle_backup.img of=/dev/mmcblk1 bs=16M ## comment the line above if this line is uncommented

##if you only need the root partition
#dd if=/dev/mmcblk1p2 of=/mnt/beagle_backup.img bs=16M ## comment the line below if this line is uncommented
#dd if=/mnt/beagle_backup.img of=/dev/mmcblk1p2 bs=16M ## comment the line above if this line is uncommented

sync
echo default-on > /sys/class/leds/beaglebone\:green\:usr0/trigger

