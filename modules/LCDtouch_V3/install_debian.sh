#!/bin/sh
echo "Compiling the main device tree from .dts to .dtb"
dtc -O dtb -o am335x-boneblack.dtb -b 0 -@ am335x-boneblack.dts
mv /boot/uboot/dtbs/am335x-boneblack.dtb /boot/uboot/dtbs/am335x-boneblack.orig.dtb
cp am335x-boneblack.dtb /boot/uboot/dtbs/

echo "Compiling the LCD overlay from .dts to .dtbo"
dtc -O dtb -o LCDtouch5-00A0.dtbo -b 0 -@ LCDtouch5-00A0.dts
cp LCDtouch5-00A0.dtbo /lib/firmware/LCDtouch5-00A0.dtbo

cd ft5x0x
make
cp ft5x0x_ts.ko /lib/modules/$(uname -r)/kernel/drivers/input/touchscreen
depmod -a
echo ft5x0x_ts > /etc/modules-load.d/ft5x0x_ts.conf
