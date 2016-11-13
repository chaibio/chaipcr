#!/bin/bash
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

if ! id | grep -q root; then
	echo "must be run as root"
	exit 1
fi

current_folder=$(pwd)
input_dir=$current_folder
BASEDIR=$(dirname $0)
sdcard_image=false

print_usage_exit () {
	echo ""
	echo "Usage: create_sdcard.sh <image folder> <block device>"
	echo "	<image folder>: the folder with factory and upgrade images"
	echo "	under <image folder>/p1 and <image folder>/p2."
	echo "	<block device>: SDCard output Block device."
	echo ""

	if [ -e /tmp/copy_mount_point ]
	then
		umount /tmp/copy_mount_point > /dev/null 2>&1
		rm -r /tmp/copy_mount_point
	fi
	if $sdcard_image
	then
		if [ -e $loopdev ]
		then
			losetup -d $loopdev
		fi
		if [ -e $loopdev ]
		then
			rm $loopdev
		fi
		if [ -e $sdcard_image_file ]
		then
			rm $sdcard_image_file
		fi
	fi

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
			echo "Can't create path: $1"
			print_usage_exit
		fi
	fi
fi

if [ -z $2 ]
then
	echo "No output device path given. Exit!"
	print_usage_exit
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
	print_usage_exit
fi

if [ ! -e ${input_dir}/p2 ]
then
	echo "Can't find input folder: ${input_dir}/p2"
	print_usage_exit
fi

image_filename_upgrade1="${input_dir}/p2/upgrade.img.tar"
image_filename_upgrade2="${input_dir}/p1/factory_settings.img.tar"

if [ ! -e $image_filename_upgrade1 ]
then
	echo "Can't find input image: $image_filename_upgrade1"
	print_usage_exit
fi

if [ ! -e $image_filename_upgrade2 ]
then
	echo "Can't find input image: $image_filename_upgrade2"
	print_usage_exit
fi

output_device=$2

if [ -z $output_device ]
then
	echo "Block device not entered."
	print_usage_exit
fi

if [ ! -b $output_device ]
then
	filename=$(basename $2)
	fileext=${filename##*.}
	if [[ $fileext == *"img"* ]]
	then
		sdcard_image_file=$2
		echo creating an sdcard image file at $sdcard_image_file
		dd if=/dev/zero of=$sdcard_image_file bs=10240K count=740
		echo sdcard image file created.. mounting it now..

		loopdev=$(losetup -f)
		if [ $? -gt 0 ]
                then
                        echo "Error creating a block device for $sdcard_image_file! No free loop devices handle. Please restart PC."
                        print_usage_exit
                fi

		loopdev_success=false
		for (( i=1; i<=50; i++))
		do
			echo creating the loop device $loopdev

			if [ -e $loopdev ]
			then
				echo $loopdev is taken.
	        	        loopdev="/dev/loop4$((RANDOM%100))"
				continue
			fi

			echo "losetup $loopdev $sdcard_image_file"
		        losetup $loopdev $sdcard_image_file
        		if [ $? -gt 0 ]
		        then
	        	        loopdev="/dev/loop4$((RANDOM%100))"
				echo error creating loop device.. trying another.
				continue
			else
				loopdev_success=true
				break
		        fi
		done

		if [ ! $loopdev_success ]
		then
			echo "Error creating a block device for $sdcard_image_file!"
			print_usage_exit
		fi
		partprobe $loopdev

		# formatting and partitioning test!
		LC_ALL=C sfdisk --force -uS --Linux $loopdev <<-__EOF__
		,4194304,0xe,*
		,,,-
		__EOF__

		partprobe $loopdev
		mkfs.ext4 "${loopdev}p1"

		output_device=$loopdev
		sdcard_image=true
	fi
fi

if [ ! -e ${output_device} ]
then
	echo "Output device not found: ${output_device}"
	print_usage_exit
fi

if [ ! -b $output_device ]
then
	echo "Entered is not a block device: $2"
	print_usage_exit
fi

if [ ! -e ${output_device} ]
then
	echo "Block device not found: ${output_device}"
	print_usage_exit
fi

if [[ ! "${output_device}" =~ "/dev/" ]]
then
	echo "Block device should start with /dev."
	print_usage_exit
fi

if [[ "${output_device}" =~ "/dev/sda" ]]
then
	echo "Block device should not be /dev/sda."
	print_usage_exit
fi

lsblk
echo "About to repartition the block device: ${output_device}.."
echo "Press CTRL+C to stop the operatin now."

#exit 0

sleep 10

echo "Unmounting..."
output_device_p1=${output_device}1
output_device_p2=${output_device}2
if [[ "${output_device}" =~ "/dev/mmc" ]] || [[ "${output_device}" =~ "/dev/loop" ]]
then
	output_device_p1=${output_device}p1
	output_device_p2=${output_device}p2
fi

echo "SDCard partitions are at: $output_device_p1, and $output_device_p2."

umount $output_device_p1 > /dev/zero
umount $output_device_p2 > /dev/zero

echo "Partitioning.."
if ! $sdcard_image
then
	if ! dd if=/dev/zero of=${output_device} bs=1M count=16
	then
		echo "Error writing to ${output_device}."
		print_usage_exit
	fi
	blockdev --flushbufs ${output_device}

	LC_ALL=C sfdisk --force -uS --Linux "${output_device}" <<-__EOF__
1,4194304,0xe,*
,,,-
__EOF__

blockdev --flushbufs ${output_device}
fi

echo "Formating..."
mkfs.vfat $output_device_p1 -n factory
if [ $? -gt 0 ]
then
	echo "Can't format ${output_device_p1}"
	print_usage_exit
fi

mkfs.ext4 $output_device_p2 -L upgrade -F
if [ $? -gt 0 ]
then
	echo "Can't format ${output_device_p2}"
	print_usage_exit
fi

sync

lsblk

echo "Copying.."

mkdir -p /tmp/copy_mount_point
sync

mount ${output_device_p1} /tmp/copy_mount_point
if [ $? -gt 0 ]
then
	echo "Can't mount ${output_device_p1}"
	print_usage_exit
fi

#echo "cp -r $input_dir/p1/* /tmp/copy_mount_point/"
cp -r $input_dir/p1/am335x-boneblack.dtb /tmp/copy_mount_point/
cp -r $input_dir/p1/* /tmp/copy_mount_point/

sync
umount /tmp/copy_mount_point
if [ $? -gt 0 ]
then
	echo "Can't unmount ${output_device_p1}"
	print_usage_exit
fi

mount ${output_device_p2} /tmp/copy_mount_point
if [ $? -gt 0 ]
then
	echo "Can't mount ${output_device_p2}"
	print_usage_exit
fi
cp -r $input_dir/p2/* /tmp/copy_mount_point/

sync
umount /tmp/copy_mount_point
if [ $? -gt 0 ]
then
	echo "Can't unmount ${output_device_p2}"
	print_usage_exit
fi
rm -r /tmp/copy_mount_point

if $sdcard_image
then
	losetup -d $loopdev
	echo sdcard image file created at: $sdcard_image_file
	echo compressing sdcard image file..
        tar cfzv ${sdcard_image_file}.tgz $sdcard_image_file
	echo sdcard image file compressed to: ${sdcard_image_file}.tgz
fi

echo "All done.."

exit 0
