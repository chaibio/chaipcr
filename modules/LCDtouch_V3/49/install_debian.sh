#!/bin/sh

apt-get  -y -q install device-tree-compiler unzip

echo "Compiling the main device tree from .dts to .dtb"

rm -r dtb-rebuilder-4.9-ti
wget https://github.com/RobertCNelson/dtb-rebuilder/archive/4.9-ti.zip
unzip 4.9-ti.zip
cd dtb-rebuilder-4.9-ti/src/arm/
patch < ../../../am33xx.dtsi.patch

cd ../..
make src/arm/am335x-boneblack-emmc-overlay.dtb 
KERNEL_VERSION=$(uname -r)

mkdir -p /boot/dtbs/$KERNEL_VERSION/
rm -r /boot/dtbs/$KERNEL_VERSION/*

cp -v src/arm/*.dtb /boot/dtbs/$KERNEL_VERSION/am335x-boneblack.dtb
cp src/arm/am335x-boneblack-emmc-overlay.dtb /boot/dtbs/*/am335x-boneblack.dtb

cd ..
rm 4.9-ti.zip
rm -r dtb-rebuilder-4.9-ti
 
cd ..

cp /boot/initrd* /boot/initrd*.org
cd ft5x0x
make

if [ -e ft5x0x_ts.ko ]
then
	cp ft5x0x_ts.ko /lib/modules/$(uname -r)/kernel/drivers/input/touchscreen
	depmod -a

	echo ft5x0x_ts > /etc/modules-load.d/ft5x0x_ts.conf
else
	echo Error compiling touch driver
	exit 1
fi

sync
exit 0
