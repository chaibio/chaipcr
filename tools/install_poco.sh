#!/bin/bash

is_def = false

echo installing POCO
if $is_dev
then
      echo Building a debug image
      cd /sdcard/upgrade/
else
      if [ -e poco-1.6.1.tar.gz ]
      then
             rm -r poco-*
      fi
fi

wget "http://pocoproject.org/releases/poco-1.6.1/poco-1.6.1.tar.gz"  || exit 1
tar xpvzf poco-1.6.1.tar.gz  || exit 1
cd poco-1.6.1
./configure || exit 1
make || exit 1

rm /usr/lib/libPoco* || true
rm /usr/local/lib/libPoco* || true

make install || exit 1
cd ..

if $is_dev
then
      echo Building a debug image
else
      rm -rf poco-1.6.1* poco-1.6.1.tar.gz
fi

