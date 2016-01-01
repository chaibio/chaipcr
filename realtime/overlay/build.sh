#!/bin/bash

echo "Compiling the overlay from .dts to .dtbo"

dtc -O dtb -o chai-pcr-00A0.dtbo -b 0 -@ chai-pcr-00A0.dts
cp chai-pcr-00A0.dtbo /lib/firmware/
