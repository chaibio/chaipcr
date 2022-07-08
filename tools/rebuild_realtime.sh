#!/bin/bash

rm -r ../build_realtime

mkdir ../build_realtime
cd ../build_realtime

/opt/QtEmbedded/bin/qmake  ../realtime/
sed -i "s/arm-unknown-linux-gnueabi-//" Makefile
sed -i '/^DEFINES[[:space:]]\+=/ s/$/ -DKERNEL_49/' Makefile

time make


