#!/bin/sh

echo "Compiling the LCD overlay from .dts to .dtbo"
dtc -O dtb -o ../CHAI-LCDtouch5-00A0.dtbo -b 0 -@ ../CHAI-LCDtouch5-00A0.dts
if [ -e ../CHAI-LCDtouch5-00A0.dtbo ]
then
	echo Tree overlay compiled ok.
else
	echo Error compiling tree overlay
	exit 1
fi


#echo "Compiling the main device tree from .dts to .dtb"
#wget https://github.com/RobertCNelson/dtb-rebuilder/archive/4.9-ti.zip
#unzip 4.9-ti.zip
#cd dtb-rebuilder-4.9-ti/
#cp ../am335x-bone-common.dtsi src/arm/am335x-bone-common.dtsi
#cpp -Wp,-MD,src/arm/.am335x-boneblack.dtb.d.pre.tmp -nostdinc -Iinclude -Isrc/arm -Itestcase-data -undef -D__DTS__ -x assembler-with-cpp -o src/arm/.am335x-boneblack.dtb.dts.tmp src/arm/am335x-boneblack.dts ; 
#dtc -O dtb -o src/arm/am335x-boneblack.dtb -b 0 -i src/arm  -d src/arm/.am335x-boneblack.dtb.d.dtc.tmp src/arm/.am335x-boneblack.dtb.dts.tmp ;
#cat src/arm/.am335x-boneblack.dtb.d.pre.tmp src/arm/.am335x-boneblack.dtb.d.dtc.tmp > src/arm/.am335x-boneblack.dtb.d

#find /boot/dtbs/* -maxdepth 1 -type d -exec mv {}/am335x-boneblack.dtb {}/am335x-boneblack.dtb.org \;
#find /boot/dtbs/* -maxdepth 1 -type d -exec cp src/arm/am335x-boneblack.dtb {}/am335x-boneblack.dtb \;
#cd ..
cd ..

cp CHAI-LCDtouch5-00A0.dtbo /lib/firmware/CHAI-LCDtouch5-00A0.dtbo

#rm 49/4.9-ti.zip
#rm -r 49/dtb-rebuilder-4.9-ti/

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

echo "cape_enable=bone_capemgr.enable_partno=chai-pcr,CHAI-LCDtouch5" >> /boot/uEnv.txt
echo "cape_disable=bone_capemgr.disable_partno=BB-BONELT-HDMI,BB-BONELT-HDMIN,BB-SPIDEV0,BB-SPIDEV1,BB-BONE-EMMC-2G" >> /boot/uEnv.txt
echo "dtb=am335x-boneblack-emmc-overlay.dtb" >> /boot/uEnv.txt
sed -i -e 's:enable_uboot_cape_universal=1::g' /boot/uEnv.txt
sed -i -e 's:cape_universal=enable:cape_universal=disable:g' /boot/uEnv.txt

sync

#echo CHAI-LCDtouch5 > $SLOTS
#cat $SLOTS

exit 0
