#!/bin/sh
echo "Compiling the main device tree from .dts to .dtb"
dtc -O dtb -o am335x-boneblack.dtb -b 0 -@ am335x-boneblack.dts
mv /boot/uboot/dtbs/am335x-boneblack.dtb /boot/uboot/dtbs/am335x-boneblack.orig.dtb
cp am335x-boneblack.dtb /boot/uboot/dtbs/

echo "Compiling the LCD overlay from .dts to .dtbo"
dtc -O dtb -o CHAI-LCD5-00A0.dtbo -b 0 -@ CHAI-LCD5-00A0.dts
cp CHAI-LCD5-00A0.dtbo /lib/firmware/CHAI-LCD5-00A0.dtbo

dtc -O dtb -o CHAI-TOUCH5-00A0.dtbo -b 0 -@ CHAI-ILITEKTOUCH5-00A0.dts
cp CHAI-TOUCH5-00A0.dtbo /lib/firmware/CHAI-TOUCH5-00A0.dtbo

cp capemgr /etc/default/

cp dtbo /etc/initramfs-tools/hooks/

cp /boot/uboot/initrd.img /boot/uboot/initrd.img.bak

/opt/scripts/tools/update_initrd.sh

cd ili2139c
make
cp ili210x.ko /lib/modules/$(uname -r)/kernel/drivers/input/touchscreen
depmod -a
echo ili210x > /etc/modules-load.d/ili210x.conf

