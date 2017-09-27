#!/bin/sh

echo "Compiling the LCD overlay from .dts to .dtbo"
dtc -O dtb -o CHAI-LCDtouch5-00A0.dtbo -b 0 -@ CHAI-LCDtouch5-00A0.dts
if [ -e CHAI-LCDtouch5-00A0.dtbo ]
then
	echo Tree overlay compiled ok.
else
	echo Error compiling tree overlay
	exit 1
fi

echo "Compiling the main device tree from .dts to .dtb"
dtc -O dtb -o am335x-boneblack.dtb -b 0 -@ am335x-boneblack.dts.49

find /boot/dtbs/* -maxdepth 1 -type d -exec mv {}/am335x-boneblack.dtb {}/am335x-boneblack.dtb.org \;
# until fixing dts find /boot/dtbs/* -maxdepth 1 -type d -exec cp am335x-boneblack.dtb {}/am335x-boneblack.dtb \;

cp CHAI-LCDtouch5-00A0.dtbo /lib/firmware/CHAI-LCDtouch5-00A0.dtbo

cp capemgr /etc/default/

cp dtbo /etc/initramfs-tools/hooks/

cp /boot/initrd* /boot/initrd*.org

/opt/scripts/tools/developers/update_initrd.sh

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

echo CHAI-LCDtouch5 > $SLOTS
cat $SLOTS

exit 0
