!/bin/sh

mkdir /root/sdcard
mount /dev/mmcblk0p1 /root/sdcard
mkdir /root/sdcard/images
rm /root/sdcard/images/*

dd if=/dev/mmcblk1p1 bs=16M of=/root/sdcard/images/mmcblk1p1.img
dd if=/dev/mmcblk1p2 bs=16M of=/root/sdcard/images/mmcblk1p2.img
dd if=/dev/mmcblk1p3 bs=16M of=/root/sdcard/images/mmcblk1p3.img
dd if=/dev/mmcblk1p4 bs=16M of=/root/sdcard/images/mmcblk1p4.img

echo "All images grabbed!"
echo default-on > /sys/class/leds/beaglebone\:green\:usr0/trigger
echo default-on > /sys/class/leds/beaglebone\:green\:usr1/trigger
echo default-on > /sys/class/leds/beaglebone\:green\:usr2/trigger
echo default-on > /sys/class/leds/beaglebone\:green\:usr3/trigger


