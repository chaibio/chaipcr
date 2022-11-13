#!/bin/bash

download_prefix="http://10.0.1.20/download"
is_dev=true

echo installing QT
dpkg --configure -a

apt-get update
apt-get install -y -q libfontconfig1-dev libfreetype6-dev

echo downloading compiled QT v4.8.6
mkdir -p /sdcard/upgrade/install_qt/
cd /sdcard/upgrade/install_qt
#wget $download_prefix/qt-everywhere-compiled-4.8.6.tgz
#wget $download_prefix/qt-everywhere-slim-4.8.6.tgz
cp /sdcard/upgrade/qt-everywhere-slim-4.8.6.tgz .
tar xfv qt-everywhere-slim-4.8.6.tgz

echo installing tslib first
cd tslib-compile/tslib/
make install  #|| exit 1
cd ../..

echo downloading QT binaries 
rm -r /opt/QtEmbedded
cd qt-everywhere-opensource-src-4.8.6/
make install #|| exit 1

mv opt/QtEmbedded /opt
rm -r /opt/QtEmbedded/examples/

cp /opt/QtEmbedded/bin /usr/lib/arm-linux-gnueabihf/qt4/ -r || true

echo done installing QT to /opt/

if $is_dev
then
      echo Building a debug image
else
    cd /sdcard/upgrade/
    rm -r qt-everywhere-opensource-src-4.8.6
    rm qt-everywhere-compiled-4.8.6.tgz
    rm qt-everywhere-slim-4.8.6.tgz
    rm -r tslib-compile
    rm -r opt
    cd
fi
sync

exit 0

