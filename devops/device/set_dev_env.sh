#!/bin/bash

#download_prefix="http://192.168.1.201/download/support_files"
download_prefix="http://10.0.1.20/download"
branch_name="trunk"

apt-get -q -y  install libfftw3-dev libgmp3-dev libmpfr-dev libblas-dev liblapack-dev libedit-dev parted git ntp ntpdate build-essential curl python pkg-config libssl-dev libarpack2 libblas3 liblapack3 libfontconfig1-dev libfreetype6-dev

echo installing headers...
uname=`uname -r`
echo uname=$uname
uname_updated=$(echo "$uname" | sed "s/chai-//")
echo updated to $uname_updated

apt-get -y -q install linux-headers-$uname_updated || exit 1
mv /usr/src/linux-headers-$uname_updated /usr/src/linux-headers-`uname -r`
ln -nfs /usr/src/linux-headers-`uname -r` /lib/modules/`uname -r`/build 
ln -nfs /usr/src/linux-headers-`uname -r` /lib/modules/`uname -r`/source

apt-get -y -q purge qt4-*

cd /sdcard/upgrade/
#wget $download_prefix/qt-everywhere-compiled-4.8.6.tgz
wget $download_prefix/qt-everywhere-slim-4.8.6.tgz
tar xfv qt-everywhere-slim-4.8.6.tgz

echo installing tslib first
cd tslib-compile/tslib/
make install  || true # could be installed before
cd ../..

echo downloading QT binaries
#cd qt-everywhere-opensource-src-4.8.6/
#make install || exit 1

mkdir -p /sdcard/upgrade/backup.2del/
mv /opt/QtEmbedded /sdcard/upgrade/backup.2del/
rm -r /opt/QtEmbedded
mv opt/QtEmbedded /opt
rm -r /opt/QtEmbedded/examples/

cp /opt/QtEmbedded/bin /usr/lib/arm-linux-gnueabihf/qt4/ -r || true
echo done installing QT to /opt/
rm -r /var/cache/apt /opt/QtEmbedded/imports /opt/QtEmbedded/translations /opt/QtEmbedded/tests ||  true

echo compiling realtime

free -m
sync

rm -r /sdcard/upgrade/realtime-compile || true
mkdir -p /sdcard/upgrade/realtime-compile || exit 1
cd /sdcard/upgrade/realtime-compile || exit 1

branch_param=
branch_name=

if [ -z $build_branch ] || ! [[ "$build_branch" == *\/* ]]  || [ "$build_branch" = "trunk" ]
then
        echo No build branch chosen
else
         branch_param="-b $(echo $build_branch | cut -d'/' -f 2)"
         branch_name="$(echo $build_branch | cut -d'/' -f 2)"
	echo Cloning branch $branch_param
fi

git clone $branch_param https://github.com/chaibio/chaipcr.git || exit 1
cd chaipcr
if [ -z $build_branch ] || ! [[ "$build_branch" == *\/* ]]  || [ "$build_branch" = "trunk" ]
then
        echo No build branch chosen
else
     	git checkout $branch_name
fi

cd /sdcard/upgrade/realtime-compile/chaipcr/realtime || exit 1

cp util/instance.h control/
sed -i "s/dataSapce/dataSpace/" app/experimentcontroller.cpp
rm libraries/lib/libPoco*
rm libraries/lib/libboost*
rm libraries/lib/libsoci*

export QMAKESPEC=/opt/QtEmbedded/mkspecs/linux-g++
#qmake
/opt/QtEmbedded/bin/qmake || exit 1

sed -i "s/arm-unknown-linux-gnueabi-//" Makefile
sed -i '/^DEFINES[[:space:]]\+=/ s/$/ -DKERNEL_49/' Makefile

make || exit 1
make install || exit 1
#cp realtime ~/tmp
cp libraries/lib/* /usr/lib/

free -m
df -h

exit 0

echo  Deploy realtime to ~/tmp
cp ~/chaipcr/deploy/device/realtime.service /lib/systemd/system/ || exit 1
systemctl enable realtime.service

sync

