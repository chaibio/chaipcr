#!/bin/bash

echo "Compiling the overlay from .dts to .dtbo"
uname -a | grep -q " 4."
if [ $? -eq 0 ]
then
	echo A new kernel detected
	dtc -O dtb -o chai-pcr-00A0.dtbo -b 0 -@ 49/chai-pcr-00A0.dts
else
	dtc -O dtb -o chai-pcr-00A0.dtbo -b 0 -@ chai-pcr-00A0.dts
fi

cp chai-pcr-00A0.dtbo /lib/firmware/
