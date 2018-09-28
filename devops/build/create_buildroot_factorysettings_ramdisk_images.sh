#!/bin/bash

apt update
apt upgrade -y
apt install -y git make gcc g++ build-essential ncurses-dev python unzip bc u-boot-tools binutils perl cpio rsync ncurses-dev gcc-multilib

git clone https://github.com/buildroot/buildroot.git
mv buildroot buildroot_cpio
cd buildroot_cpio
git checkout 2018.05

>board/beaglebone/uEnv.txt
cat << EOF >> board/beaglebone/uEnv.txt
bootpart=0:1
bootdir=
fdtaddr=0x81FF0000
optargs=quiet capemgr.disable_partno=BB-BONELT-HDMI,BB-BONELT-HDMIN
uenvcmd=setenv fdtfile am335x-boneblack.dtb;load mmc 0 ${loadaddr} uImage;fatload mmc 0:1 ${fdtaddr} ${fdtfile};setenv bootargs console=${console} ${optargs};bootm ${loadaddr} - ${fdtaddr}
EOF

make beaglebone_defconfig

cat << EOF >> .config

BR2_LINUX_KERNEL_ZIMAGE=n
BR2_LINUX_KERNEL_UIMAGE=y
BR2_LINUX_KERNEL_UIMAGE_LOADADDR="0x80008000"
BR2_PACKAGE_HOST_UBOOT_TOOLS=y
BR2_TARGET_ROOTFS_CPIO=y
BR2_TARGET_ROOTFS_CPIO_NONE=y
BR2_TARGET_ROOTFS_INITRAMFS=y
BR2_TARGET_ROOTFS_CPIO_UIMAGE=y
BR2_TARGET_ROOTFS_INITRAMFS=y
BR2_TARGET_ROOTFS_CPIO_GZIP=y
BR2_TARGET_ROOTFS_CPIO=y
BR2_TARGET_ROOTFS_CPIO_NONE=y
# BR2_TARGET_ROOTFS_CPIO_GZIP is not set
# BR2_TARGET_ROOTFS_CPIO_BZIP2 is not set
# BR2_TARGET_ROOTFS_CPIO_LZ4 is not set
# BR2_TARGET_ROOTFS_CPIO_LZMA is not set
# BR2_TARGET_ROOTFS_CPIO_LZO is not set
# BR2_TARGET_ROOTFS_CPIO_XZ is not set
# BR2_TARGET_ROOTFS_CRAMFS is not set
# BR2_PACKAGE_HOST_UBOOT_TOOLS_FIT_SUPPORT is not set

BR2_LINUX_KERNEL_CONFIG_FRAGMENT_FILES="cpio.fragment"
EOF
cat << EOF >> cpio.fragment
CONFIG_UIMAGE_LOADADDR=0x80008000
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE="../../images/rootfs.cpio.gz"
CONFIG_INITRAMFS_ROOT_UID=0
CONFIG_INITRAMFS_ROOT_GID=0
CONFIG_RD_GZIP=y
CONFIG_CRAMFS=y
EOF

#make menuconfig
time make source

mkdir -p system/skeleton/etc/init.d/
cat << EOF >> system/skeleton/etc/init.d/S99autorun
#!/bin/sh
#
# Run autorun.sh on /dev/mmcblk0p1
#

case "\$1" in
  start|restart)
        echo "Running CHAIBIO autorun at /dev/mmcblk0p1/autorun.sh..."
        /bin/mount /dev/mmcblk0p1 /mnt
        [ -e /mnt/autorun.sh ] && . /mnt/autorun.sh
        /bin/umount /mnt
        ;;
  *)
        echo "Usage: autorun {start}"
        exit 1
esac

exit \$?
EOF
chmod +x system/skeleton/etc/init.d/S99autorun

mkdir -p output/images
touch output/images/rootfs.cpio.gz
touch output/images/zImage

sed -i "s/16M/96M/g" board/beaglebone/genimage.cfg
sed -i "s/16M/96M/g" board/beaglebone/genimage_linux41.cfg

#make linux-menuconfig
time make

cd output/images
ls -ahl MLO uImage u-boot.img

echo all done

