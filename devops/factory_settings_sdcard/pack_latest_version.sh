#!/bin/bash

if ! id | grep -q root; then
	echo "must be run as root"
	exit 1
fi

if [ -e /dev/mmcblk1p4 ] ; then
	sdcard_dev="/dev/mmcblk0"
	eMMC="/dev/mmcblk1"
fi

if [ -e /dev/mmcblk0p4 ] ; then
	sdcard_dev="/dev/mmcblk1"
	eMMC="/dev/mmcblk0"
fi

if [ ! -e "${eMMC}p4" ]
then
        echo "Proper eMMC partitionining not found!"
	exit 1
fi

check_running_system
echo timer > /sys/class/leds/beaglebone\:green\:usr0/trigger 
sdcard="/sdcard"

image_filename_folder="${sdcard}/tmp"
image_filename_prfx="upgrade"
image_filename_rootfs="$image_filename_prfx-rootfs.img.gz" 
image_filename_data="$image_filename_prfx-data.img.gz"
image_filename_boot="$image_filename_prfx-boot.img.gz"
image_filename_pt="$image_filename_prfx-pt.img.gz"
image_filename_upgrade_tar_temp="${sdcard}/tmp/temp.tar"
image_filename_upgrade_temp="${sdcard}/tmp/temp.tar.gz"
image_filename_upgrade="${sdcard}/upgrade.img.gz"

echo "Packing eMMC image.."

umount ${sdcard} || true
mount ${sdcard_dev}p1 ${sdcard} || true

cd $image_filename_folder

if [ -e  $image_filename_upgrade_tar_temp ]
then
	rm $image_filename_upgrade_tar_temp
fi

if [ -e $image_filename_upgrade_temp ]
then
	rm $image_filename_upgrade_temp
fi

if [ -e $image_filename_upgrade ]
then
	rm $image_filename_upgrade
fi

if [ ! -e ${sdcard}/tmp ]
then
        mkdir -p ${sdcard}/tmp/
fi

#umount ${sdcard} || true
#mount ${sdcard_dev}p1 ${sdcard} || true

#initiat auto run on first run for the eMMC after the upgrade.
echo mounting rootfs partition

mkdir -p /tmp/emmcp2
mount ${eMMC}p2 /tmp/emmcp2
echo "#!/bin/bash" >  /tmp/emmcp2/opt/scripts/boot/autorun.upgrade.sh
echo "cd /mnt/root/chaipcr/web" >> /tmp/emmcp2/opt/scripts/boot/autorun.upgrade.sh
echo "bundle exec rake db:migrate" >> /tmp/emmcp2/opt/scripts/boot/autorun.upgrade.sh
echo "bundle exec rake db:seed_fu" >> /tmp/emmcp2/opt/scripts/boot/autorun.upgrade.sh
echo "cd" >> /tmp/emmcp2/opt/scripts/boot/autorun.upgrade.sh
chmod +x /tmp/emmcp2/opt/scripts/boot/autorun.upgrade.sh
sync
umount /tmp/emmcp2

#exit

#copy eMMC contents
echo "Copying eMMC partitions at $eMMC"
sync
echo "Backing up partition table to: $image_filename_pt"
dd  if=${eMMC} bs=16M count=1 | gzip -c > $image_filename_pt

sleep 5
sync

echo "Backing up binaries partition to: $image_filename_rootfs"
dd  if=${eMMC}p2 bs=16M | gzip -c > $image_filename_rootfs

sleep 5
sync

echo "Packing up boot partition to: $image_filename_boot"
dd  if=${eMMC}p1 bs=16M | gzip -c > $image_filename_boot

#compressing
#echo "tar -cvf $image_filename_upgrade_tar_temp $image_filename_pt $image_filename_boot $image_filename_rootfs"

echo "compressing all images to $image_filename_upgrade_tar_temp"

tar -cvf $image_filename_upgrade_tar_temp $image_filename_pt $image_filename_boot $image_filename_rootfs
#exit


echo "Pack images tar to $image_filename_upgrade_temp"
gzip $image_filename_upgrade_tar_temp

echo "Remove packed files"
#mv $image_filename_upgrade_temp $image_filename_upgrade

if [ -e $image_filename_boot ]
then
	rm $image_filename_boot
else
       	echo "Boot image not found: $image_filename_boot"
fi

if [ -e $image_filename_rootfs ]
then
	rm $image_filename_rootfs
else
        echo "Rootfs image not found: $image_filename_rootfs"
fi

if [ -e $image_filename_pt ]
then
	rm $image_filename_pt
fi

echo "Finalizing: $image_filename_upgrade"
mv $image_filename_upgrade_temp $image_filename_upgrade

echo "Removing packing autorun script from eMMC!"

#mkdir -p /tmp/emmcp2
mount ${eMMC}p2 /tmp/emmcp2
rm /tmp/emmcp2/opt/scripts/boot/autorun.upgrade.sh
sync
umount /tmp/emmcp2

echo "Finished.. byebye!"

rm ${sdcard}/pack_resume_autorun.flag || true > /dev/null

sync
echo default-on > /sys/class/leds/beaglebone\:green\:usr0/trigger

exit 0
