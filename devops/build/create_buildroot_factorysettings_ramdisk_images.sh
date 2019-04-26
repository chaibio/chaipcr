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

BR2_LINUX_KERNEL_CONFIG_FRAGMENT_FILES="linux.fragment"
EOF
cat << EOF >> linux.fragment

#
# cpio - ram disk
#
CONFIG_UIMAGE_LOADADDR=0x80008000
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE="../../images/rootfs.cpio.gz"
CONFIG_INITRAMFS_ROOT_UID=0
CONFIG_INITRAMFS_ROOT_GID=0
CONFIG_RD_GZIP=y
CONFIG_CRAMFS=y

#
# Triggers - standalone
#
CONFIG_IIO_PERIODIC_RTC_TRIGGER=m
CONFIG_IIO_GPIO_TRIGGER=m
CONFIG_IIO_SYSFS_TRIGGER=m
# CONFIG_IIO_SIMPLE_DUMMY is not set
# CONFIG_ZSMALLOC is not set
# CONFIG_TIDSPBRIDGE is not set
# CONFIG_USB_ENESTORAGE is not set
# CONFIG_BCM_WIMAX is not set
# CONFIG_FT1000 is not set

#
# LED Triggers
#
CONFIG_LEDS_TRIGGER_TIMER=y
CONFIG_LEDS_TRIGGER_ONESHOT=y
CONFIG_LEDS_TRIGGER_HEARTBEAT=y
CONFIG_LEDS_TRIGGER_BACKLIGHT=y
CONFIG_LEDS_TRIGGER_CPU=y
CONFIG_LEDS_TRIGGER_GPIO=y
CONFIG_LEDS_TRIGGER_DEFAULT_ON=y

#
# LED Triggers
#
CONFIG_LEDS_TRIGGER_TIMER=y
CONFIG_LEDS_TRIGGER_ONESHOT=y
CONFIG_LEDS_TRIGGER_HEARTBEAT=y
CONFIG_LEDS_TRIGGER_BACKLIGHT=y
CONFIG_LEDS_TRIGGER_CPU=y
CONFIG_LEDS_TRIGGER_GPIO=y
CONFIG_LEDS_TRIGGER_DEFAULT_ON=y

#
# MMC/SD/SDIO Host Controller Drivers
#
# CONFIG_MMC_SDHCI is not set
# CONFIG_MMC_SDHCI_PXAV3 is not set
# CONFIG_MMC_SDHCI_PXAV2 is not set
CONFIG_MMC_OMAP=y
CONFIG_MMC_OMAP_HS=y
# CONFIG_MMC_DW is not set
# CONFIG_MMC_VUB300 is not set
# CONFIG_MMC_USHC is not set
# CONFIG_MEMSTICK is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# Magnetometer sensors
#
CONFIG_HID_SENSOR_MAGNETOMETER_3D=m
CONFIG_IIO_ST_MAGN_3AXIS=m
CONFIG_IIO_ST_MAGN_I2C_3AXIS=m
CONFIG_IIO_ST_MAGN_SPI_3AXIS=m
CONFIG_PWM=y
CONFIG_PWM_SYSFS=y
CONFIG_PWM_PCA9685=m
CONFIG_PWM_TIECAP=y
CONFIG_PWM_TIEHRPWM=y
CONFIG_PWM_TIPWMSS=y
# CONFIG_PWM_TWL is not set
# CONFIG_PWM_TWL_LED is not set
CONFIG_EHRPWM_TEST=m
# CONFIG_IPACK_BUS is not set
CONFIG_RSTCTL=y
CONFIG_RSTCTL_GPIO=y
CONFIG_RSTCTL_TEST=y
CONFIG_RSTCTL_TEST_CONSUMER=y

CONFIG_MAC80211_RC_DEFAULT="pid"
CONFIG_MAC80211_MESH=y
CONFIG_MAC80211_LEDS=y
CONFIG_MAC80211_DEBUGFS=y

CONFIG_WIMAX=m
CONFIG_WIMAX_DEBUG_LEVEL=8
CONFIG_RFKILL=m
CONFIG_RFKILL_LEDS=y
CONFIG_RFKILL_INPUT=y
CONFIG_RFKILL_REGULATOR=m
CONFIG_RFKILL_GPIO=m
CONFIG_NET_9P=m
CONFIG_NET_9P_VIRTIO=m

CONFIG_CARL9170=m
CONFIG_CARL9170_LEDS=y

CONFIG_AT76C50X_USB=m
CONFIG_USB_ZD1201=m
CONFIG_USB_NET_RNDIS_WLAN=m
CONFIG_RTL8187=m
CONFIG_RTL8187_LEDS=y

CONFIG_HID_PICOLCD_LEDS=y

CONFIG_KEYBOARD_GPIO=y
CONFIG_INPUT_GPIO_ROTARY_ENCODER=m
CONFIG_I2C_MUX_GPIO=y

CONFIG_PPS_CLIENT_GPIO=y

CONFIG_ARCH_HAVE_CUSTOM_GPIO_H=y

CONFIG_ARCH_REQUIRE_GPIOLIB=y
CONFIG_GPIOLIB=y
CONFIG_OF_GPIO=y
CONFIG_DEBUG_GPIO=y
CONFIG_GPIO_SYSFS=y
CONFIG_GPIO_OF_HELPER=y
CONFIG_GPIO_PCF857X=y
CONFIG_GPIO_TWL4030=y

CONFIG_W1_MASTER_GPIO=y

CONFIG_CHARGER_GPIO=m

CONFIG_SENSORS_GPIO_FAN=m

CONFIG_REGULATOR_GPIO=y

CONFIG_IR_GPIO_CIR=m

CONFIG_USB_GPIO_VBUS=m

CONFIG_LEDS_GPIO=y
CONFIG_LEDS_LM3642=m
CONFIG_LEDS_GPIO=y

CONFIG_LEDS_PWM=y
CONFIG_LEDS_LM355x=m
CONFIG_LEDS_BLINKM=m
CONFIG_LEDS_TRIGGERS=y

CONFIG_LEDS_TRIGGER_TRANSIENT=y
# CONFIG_ACCESSIBILITY is not set
# CONFIG_EDAC is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
CONFIG_RTC_HCTOSYS=y
CONFIG_RTC_HCTOSYS_DEVICE="rtc0"

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

