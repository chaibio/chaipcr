#!/bin/bash


cd ~
tar fvzc /sdcard/upgrade/dot_julia.tgz .julia 
cd /sdcard/upgrade/
tar fvzx /sdcard/upgrade/dot_julia.tgz
rm -r ~/.julia
ln -s /sdcard/upgrade/.julia/ /root/.julia 

# creating a temporary swap file on sdcard
swapoff -v /tmp/swapfile
if fallocate -l 2G /sdcard/upgrade/swapfile #or dd if=/dev/zero of=/sdcard/upgrade/swapfile bs=10M count=300
then
    echo "swap file created successfully"
else
   echo "failed creating swap file"
   exit 1
fi

sudo chmod 600 /sdcard/upgrade/swapfile
sudo mkswap /sdcard/upgrade/swapfile
sudo swapon /sdcard/upgrade/swapfile

#verifying swap file is successfully added
sudo swapon -s
sync
swapoff -v /tmp/swapfile
sync
rm /tmp/swapfile
free -m


rm -r /usr/doc/*
rm -r /usr/man/*
rm -r /tmp/*

df -h


exit 0

