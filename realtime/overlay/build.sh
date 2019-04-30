#!/bin/bash

echo "Compiling the overlay from .dts to .dtbo"
uname -a | grep -q " 4."
if [ $? -eq 0 ]
then
	echo 4.x kernel detected. This kernel use no cape manager. Nothing to do. Exit.
	exit 1
else
	dtc -O dtb -o chai-pcr-00A0.dtbo -b 0 -@ chai-pcr-00A0.dts
fi

cp chai-pcr-00A0.dtbo /lib/firmware/
exit 0
