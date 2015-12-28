#!/bin/bash

if ! id | grep -q root; then
	echo "must be run as root"
	exit 1
fi

current_folder=$(pwd)
input_dir=$current_folder
BASEDIR=$(dirname $0)

print_usage_exit () {
	echo "	Usage: create_sdcard.sh <image folder> <block device>"
	echo "		<image folder>: the folder with factory and upgrade images"
	echo "		under <image folder>/p1 and <image folder>/p2."
	echo "		<block device>: SDCard output Block device."
	exit 1
}

if [ "$1" = "man" ]
then
	print_usage_exit
fi

if [ -z $1 ]
then
	echo "No images path given."
	print_usage_exit
else
	input_dir=$1
	if [ -e $1 ]
	then
		echo "Path found: $1"
	else
		mkdir -p $1
		if [ -e $1 ]
		then
			echo "Path created: $1"
			BASEDIR=$(dirname $0)
			echo copying card contents from $BASEDIR/factory_settings_sdcard/ to $input_dir/p1
			if [ ! -e ${input_dir}/p1 ]
			then
				mkdir -p ${input_dir}/p1
			fi
			cp -r $BASEDIR/factory_settings_sdcard/* $input_dir/p1
		else
			echo "Cann't create path: $1"
			exit 1
		fi
	fi
fi

if [ -z $2 ]
then
	echo "No output device path given. Exit!"
	exit 1
else
	output_device=$2
	if [ -e $2 ]
	then
		echo "Device found: $2"
	fi
fi

if [ ! -e ${input_dir}/p1 ]
then
	echo "Can't find input folder: ${input_dir}/p1"
	exit 1
fi

if [ ! -e ${input_dir}/p2 ]
then
	echo "Can't find input folder: ${input_dir}/p2"
	exit 1
fi

if [ ! -e ${output_device} ]
then
	echo "Output device not found: ${input_dir}"
	exit 1
fi

image_filename_upgrade1="${input_dir}/p2/upgrade.img.gz"
image_filename_upgrade2="${input_dir}/p1/factory_settings.img.gz"

if [ ! -e $image_filename_upgrade1 ]
then
	echo "Can't find input image: $image_filename_upgrade1"
	exit 1
fi

if [ ! -e $image_filename_upgrade2 ]
then
	echo "Can't find input image: $image_filename_upgrade2"
	exit 1
fi

if [ -z $2 ]
then
	echo "Block device not entered."
	print_usage_exit
fi

if [ ! -b $2 ]
then
	echo "Entered is not a block device: $2"
	print_usage_exit
fi

output_device=$2

if [ ! -e ${output_device} ]
then
	echo "Block device not found: ${output_device}"
	print_usage_exit
fi

if [[ "${output_device}" =~ "/dev/" ]]
then
	echo "Block device should start with /dev."
	print_usage_exit
fi

if [[ "${output_device}" =~ "/dev/sda" ]]
then
	echo "Block device should not be /dev/sda."
	print_usage_exit
fi

mount ${output_device} > /dev/zero
if [ $? -eq 0 ]
then
	echo "File system is already mounted: ${output_device}"
	lsblk
	exit 1
fi

echo "About to repartition the block device: ${output_device}.. press CTRL+C to stop the operatin."
sleep 10

echo "Partitioning.."
dd if=/dev/zero of=${output_device} bs=1M count=16
blockdev --flushbufs ${output_device}

LC_ALL=C sfdisk --force --in-order --Linux --unit M "${output_device}" <<-__EOF__
1,2048,0xe,*
,,,-
__EOF__

blockdev --flushbufs ${output_device}

echo "Formating..."
mkfs.vfat -F 16 ${output_device}1 -n factory
mkfs.ext4 ${output_device}2 -L upgrade

lsblk

echo "Copying.."
mkdir -p /tmp/copy_mount_point
mount ${output_device}1 /tmp/copy_mount_point
cp -r $input_dir/p1/* /tmp/copy_mount_point
sync
umount /tmp/copy_mount_point

mount ${output_device}2 /tmp/copy_mount_point
cp -r $input_dir/p2/* /tmp/copy_mount_point
sync
umount /tmp/copy_mount_point
rm -r /tmp/copy_mount_point

exit 0
