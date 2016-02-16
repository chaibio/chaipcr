#!/bin/bash

boot=/boot/uboot
if [ $# -gt 0 ]
then
	boot=$1

fi
echo "Boot partition path is: $boot"
if [ ! -e $boot ]
then
	echo "Boot path not found: $boot"
	exit 1
fi



uEnv=$boot/uEnv.txt
uEnvSDCard=$boot/uEnv.sdcard.txt
uEnv72Check=$boot/uEnv.72check.txt
NOW=$(date +"%m-%d-%Y %H:%M:%S")








cat << _EOF_ > $uEnv
##Video: Uncomment to override:
##see: https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/Documentation/fb/modedb.txt
#kms_force_mode=video=HDMI-A-1:1024x768@60e
optargs=consoleblank=0
optargs=splash plymouth.ignore-serial-consoles \${optargs}
##Enable systemd
systemd=quiet init=/lib/systemd/systemd

##BeagleBone Cape Overrides

##BeagleBone Black:
##Disable HDMI/eMMC
#cape_disable=capemgr.disable_partno=BB-BONELT-HDMI,BB-BONELT-HDMIN,BB-BONE-EMMC-2G

##Disable HDMI
cape_disable=capemgr.disable_partno=BB-BONELT-HDMI,BB-BONELT-HDMIN
#cape_disable=capemgr.disable_partno=BB-BONELT-HDMIN

##Audio Cape (needs HDMI Audio disabled)
#cape_disable=capemgr.disable_partno=BB-BONELT-HDMI
#cape_enable=capemgr.enable_partno=BB-BONE-AUDI-02

##Example
#cape_disable=capemgr.disable_partno=
#cape_enable=capemgr.enable_partno=

##WIP: v3.14+ capes..
#cape=ttyO1
#cape=

##note: the eMMC flasher script relies on the next line
_EOF_


UUID=$(blkid /dev/mmcblk1p2 | awk -FUUID=\" '{print $2}' | awk -F\" '{print $1}')
UUID_p3=$(blkid /dev/mmcblk1p3 | awk -FUUID=\" '{print $2}' | awk -F\" '{print $1}')
UUID_p4=$(blkid /dev/mmcblk1p4 | awk -FUUID=\" '{print $2}' | awk -F\" '{print $1}')
EMMC=/dev/mmcblk1p2
if [ -z $UUID ]
then
	echo "/dev/mmcblk1 is not a valid block device"
	UUID=$(lsblk -no UUID /dev/mmcblk0p2)
	UUID_p3=$(blkid /dev/mmcblk0p3 | awk -FUUID=\" '{print $2}' | awk -F\" '{print $1}')
	UUID_p4=$(blkid /dev/mmcblk0p4 | awk -FUUID=\" '{print $2}' | awk -F\" '{print $1}')
        EMMC=/dev/mmcblk1p2
	if [ -z $UUID ]
	then
		echo "Cann't find a booting root!"
		exit 0
	fi
fi

echo "Root fs Block device found at $UUID"
echo "/data partition found at $UUID_p3"
echo "/perm partition found at $UUID_p4"

#exit

cat << _EOF_ >> $uEnv
mmcroot=UUID=${UUID} ro
mmcrootfstype=ext4 rootwait fixrtc

##These are needed to be compliant with Angstrom's 2013.06.20 u-boot.
console=ttyO0,115200n8

kernel_file=zImage
initrd_file=initrd.img

loadaddr=0x82000000
initrd_addr=0x88080000
fdtaddr=0x88000000

initrd_high=0xffffffff
fdt_high=0xffffffff

loadkernel=load mmc \${mmcdev}:\${mmcpart} \${loadaddr} \${kernel_file}
loadinitrd=load mmc \${mmcdev}:\${mmcpart} \${initrd_addr} \${initrd_file}; setenv initrd_size \${filesize}
loadfdt=load mmc \${mmcdev}:\${mmcpart} \${fdtaddr} /dtbs/\${fdtfile}

loadfiles=run loadkernel; run loadinitrd; run loadfdt
mmcargs=setenv bootargs console=tty0 console=\${console} \${optargs} \${cape_disable} \${cape_enable} \${kms_force_mode} root=\${mmcroot} rootfstype=\${mmcrootfstype} \${systemd}

uenvcmdmmc=run loadfiles; run mmcargs; bootz \${loadaddr} \${initrd_addr}:\${initrd_size} \${fdtaddr}

usb_kernel_file=vmlinuz
loadusbkernel=load usb 0:1 \${loadaddr} /boot/\${usb_kernel_file}
loadusbinitrd=load usb 0:1 \${initrd_addr} /boot/\${initrd_file}; setenv initrd_size \${filesize}
loadusbfdt=load usb 0:1 \${fdtaddr} /boot/dtbs/3.8.13-bone69/\${fdtfile}
shutdown_usb_power=i2c dev 0;i2c mw 0x24 1 0xec
loadusbfiles=run loadusbkernel; run loadusbinitrd; run loadusbfdt
usbroot=/dev/sda1 ro rootwait
usbargs=setenv bootargs console=tty0 console=\${console} \${optargs} \${cape_disable} \${cape_enable} \${kms_force_mode} root=\${usbroot} rootfstype=\${mmcrootfstype} 
uenvcmdusb=run loadusbfiles; run usbargs; bootz \${loadaddr} \${initrd_addr}:\${initrd_size} \${fdtaddr}

s2pressed=0
uenvcmdmmc=echo "*** Boot button Unpressed..!!"; run loadfiles; run mmcargs; bootz \${loadaddr} \${initrd_addr}:\${initrd_size} \${fdtaddr}
uenvcmdsdcard=bootpart=0:1;bootdir=;fdtaddr=0x81FF0000;optargs=quiet capemgr.disable_partno=BB-BONELT-HDMI,BB-BONELT-HDMIN;load mmc 0 ${loadaddr} uImage;run loadfdt;setenv bootargs console=${console} ${optargs} s2pressed=${s2pressed};bootm ${loadaddr} - ${fdtaddr}
uenvcmdsdcard_s2pressed=echo "*** Boot button pressed..!!"; setenv s2pressed 1; run uenvcmdsdcard

uenvcmd=run shutdown_usb_power;if gpio input 72; then run uenvcmdsdcard_s2pressed; else run uenvcmdmmc; fi

# Updated: $NOW

_EOF_


echo "uEnv.txt done updating"

cp $uEnv $uEnvSDCard
cp $uEnv $uEnv72Check
echo " " >> $uEnvSDCard
echo "uenvcmd=run shutdown_usb_power;if gpio input 72; then run uenvcmdsdcard_s2pressed; else run uenvcmdsdcard; fi" >> $uEnvSDCard
echo "#" >> $uEnvSDCard

echo "SDCard version of uEnv.txt done updating"

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

echo "Adding automount for /data and /perm"
rootfs="/tmp/emmcrootfs"
if [ ! -e $rootfs ]
then
	mkdir -p $rootfs
fi

mount $EMMC $rootfs
fstab="$rootfs/etc/fstab"
fstab_new="$rootfs/etc/fstab_new"
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
	echo "$var"
	echo $var >> $fstab_new
done < "$fstab"

echo "UUID=$UUID_p3  /data   ext4    rw,auto,user,errors=remount-ro  0  0" >> $fstab_new
echo "UUID=$UUID_p4  /perm   ext4    rw,auto,user,errors=remount-ro  0  0" >> $fstab_new

cp $fstab "${fstab}.save"
cp $fstab_new $fstab
sync
umount $rootfs || true
rm -r $rootfs || true
