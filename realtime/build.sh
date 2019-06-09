#!/bin/bash

DEBIAN_FRONTEND=noninteractive apt-get -q -y install gettext libpango1.0-0 libglib2.0-0 libcairo2 libboost-chrono-dev libboost-system-dev git build-essential g++ make linux-headers-`uname -r` build-essential cmake curl pkg-config python sshpass unzip libsoci-dev qt5-default qt5-qmake

cp util/instance.h control/
sed -i "s/dataSapce/dataSpace/" app/experimentcontroller.cpp
#rm libraries/lib/libPoco*
#rm libraries/lib/libboost*
rm -r libraries
#/lib/libsoci*
rm -r /opt/QtEmbedded
qmake
# -spec /opt/QtEmbedded/mkspecs/linux-g++
sed -i "s/arm-unknown-linux-gnueabi-//" Makefile
sed -i '/^DEFINES[[:space:]]\+=/ s/$/ -DKERNEL_49/' Makefile
make

