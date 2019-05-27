#!/bin/bash

#cd /sdcard/upgrade/

DEBIAN_FRONTEND=noninteractive apt-get -q -y install gettext libpango1.0-0 libglib2.0-0 libcairo2 libboost-chrono-dev libboost-system-dev git build-essential g++ make linux-headers-`uname -r` build-essential cmake curl pkg-config python sshpass unzip libsoci-dev

#wget 10.0.1.20/download/qt-everywhere-slim-4.8.6.tgz
#wget 192.168.1.201/download/qt-everywhere-slim-4.8.6.tgz

#tar xfv qt-everywhere-slim-4.8.6.tgz
#echo installing tslib first
#cd tslib-compile/tslib/
#make install  
#cd ..
#mv /opt/QtEmbedded /opt/QtEmbedded_old

#mv opt/QtEmbedded /opt
#mv /opt/QtEmbedded /opt/QtEmbedded_old
#mv opt/QtEmbedded /opt

#ls /opt/QtEmbedded/bin/qmake
#git clone https://github.com/chaibio/chaipcr.git

#cd chaipcr/realtime/
cp util/instance.h control/
sed -i "s/dataSapce/dataSpace/" app/experimentcontroller.cpp
rm libraries/lib/libPoco*
rm libraries/lib/libboost*
rm libraries/lib/libsoci*
#/opt/QtEmbedded/bin/qmake
/opt/QtEmbedded/bin/qmake -spec /opt/QtEmbedded/mkspecs/linux-g++
sed -i "s/arm-unknown-linux-gnueabi-//" Makefile
sed -i '/^DEFINES[[:space:]]\+=/ s/$/ -DKERNEL_49/' Makefile
make

