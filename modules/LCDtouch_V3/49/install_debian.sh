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
cd ilitek

echo installing headers...
uname=`uname -r`
echo uname=$uname
uname_updated=$(echo "$uname" | sed "s/chai-//")
echo updated to $uname_updated

apt-get -y -q install linux-headers-$uname_updated
apt-get install -y make build-essential
make mod

if [ -e ilitek_aimv20.ko ]
then
	make install_mod
else
	echo Error compiling ilitek touch driver
	exit 1
fi

cd ../ft5x0x
make
if [ -e ft5x0x_ts.ko ]
then
	cp ft5x0x_ts.ko /lib/modules/$(uname -r)/kernel/drivers/input/touchscreen
	depmod -a
else
	echo Error compiling ft5x0x touch driver
	exit 1
fi

echo ilitek_aimv20 > /etc/modules-load.d/chaibio_touch_controller.conf

sync

exit 0
