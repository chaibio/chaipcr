#!/bin/bash

cd ../realtime

apt-get install -y git make build-essential cmake curl pkg-config python sshpass unzip
echo "Shell used: $0"


free -m
sync

cp util/instance.h control/
sed -i "s/dataSapce/dataSpace/" app/experimentcontroller.cpp
rm libraries/lib/libPoco*
rm libraries/lib/libboost*
rm libraries/lib/libsoci*

#qmake
/opt/QtEmbedded/bin/qmake || exit 1

sed -i "s/arm-unknown-linux-gnueabi-//" Makefile
sed -i '/^DEFINES[[:space:]]\+=/ s/$/ -DKERNEL_49/' Makefile

make || exit 1
make install || exit 1
cp libraries/lib/* /usr/lib/

cp ~/chaipcr/deploy/device/realtime.service /lib/systemd/system/ || exit 1
systemctl enable realtime.service

sync

exit 0
