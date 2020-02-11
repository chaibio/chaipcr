#!/bin/bash

apt update
DEBIAN_FRONTEND=noninteractive apt-get -q -y  install libfftw3-dev libgmp3-dev libmpfr-dev libblas-dev liblapack-dev libedit-dev parted git ntp ntpdate build-essential curl python pkg-config libssl-dev libarpack2 libblas3 liblapack3 g++ git i2c-tools cmake libboost-chrono-dev libboost-system-dev libfontconfig1-dev libfreetype6-dev 

cd /sdcard/upgrade/ || exit 1
free -m
sync

cd /sdcard/upgrade/
wget http://10.0.1.20/download/qt-everywhere-slim-4.8.6.tgz
tar xfv qt-everywhere-slim-4.8.6.tgz

cd tslib-compile/tslib/
make install  || exit 1
cd ../..

rm -r /opt/QtEmbedded/ || true
mv opt/QtEmbedded /opt
rm -r /opt/QtEmbedded/examples/

cp /opt/QtEmbedded/bin /usr/lib/arm-linux-gnueabihf/qt4/ -r || true

rm -r qt-everywhere-opensource-src-4.8.6
rm qt-everywhere-compiled-4.8.6.tgz
rm qt-everywhere-slim-4.8.6.tgz
rm -r tslib-compile
rm -r opt

rm -r /sdcard/upgrade/realtime-compile || true
mkdir -p /sdcard/upgrade/realtime-compile || exit 1
cd /sdcard/upgrade/realtime-compile || exit 1

git clone $branch_param https://github.com/chaibio/chaipcr.git || exit 1
cd chaipcr
# choose the branch if not master git checkout [branch name]

cd /sdcard/upgrade/realtime-compile/chaipcr/realtime || exit 1

cp util/instance.h control/
sed -i "s/dataSapce/dataSpace/" app/experimentcontroller.cpp
rm libraries/lib/libPoco*
rm libraries/lib/libboost*
rm libraries/lib/libsoci*

#qmake
/opt/QtEmbedded/bin/qmake || exit 1

sed -i "s/arm-unknown-linux-gnueabi-//" Makefile
sed -i '/^DEFINES[[:space:]]\+=/ s/$/ -DKERNEL_49/' Makefile

make 

systemctl stop realtime.service || true
make install 

cp libraries/lib/* /usr/lib/
cd

echo  Deploy realtime to ~/tmp 
cp ~/chaipcr/deploy/device/realtime.service /lib/systemd/system/ || exit 1
systemctl enable realtime.service

echo "You can now edit and build realtime application by cd /sdcard/upgrade/realtime-compile/chaipcr/realtime and then make and make install"
sync

exit 0

