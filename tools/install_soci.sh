#!/bin/bash


echo Update Software
apt-key update
apt-get update

apt-get -y -q install lsb-release
sync
sleep 30

dpkg --configure -a
sync

apt-get -q -y update
apt-get -q -y install -f

apt-get -q -y install unzip || exit 1

dpkg --configure -a

echo "FSCKFIX=yes" >> /etc/default/rcS
apt-key list  | grep "expired: " | sed -ne 's|pub .*/\([^ ]*\) .*|\1|gp' | xargs -n1 sudo apt-key adv --keyserver keys.gnupg.net --recv-keys 
apt-get -q -y update

apt-get --force-yes -y -q install nodejs ruby ruby-dev  || exit 1
sync
sleep 30
dpkg --configure -a

apt-get --force-yes -y -q install libxslt-dev libxml2-dev  || exit 1
sync
sleep 30
dpkg --configure -a

apt-get -y -q install libtool || exit 1
dpkg --configure -a
sync
sleep 30

echo installing headers...
uname=`uname -r`
echo uname=$uname
uname_updated=$(echo "$uname" | sed "s/chai-//")
echo updated to $uname_updated

apt-get -y -q install linux-headers-$uname_updated || exit 1
mv /usr/src/linux-headers-$uname_updated /usr/src/linux-headers-`uname -r`
ln -nfs /usr/src/linux-headers-`uname -r` /lib/modules/`uname -r`/build 
ln -nfs /usr/src/linux-headers-`uname -r` /lib/modules/`uname -r`/source

apt-get install -y -q cmake || exit 1


apt-get -y -q install g++ ntp ntpdate git unzip automake sshpass build-essential || true
echo done installing essentials.. 
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:%PATH% DEBIAN_FRONTEND=noninteractive apt-get install -q -y ntpdate || exit 1

echo syncing time.. 
ntpdate -b -s -u pool.ntp.org
sync



echo "Build SOCI (or get its libs from repo)"
cd ~

#http://downloads.sourceforge.net/project/soci/soci/soci-3.2.2/soci-3.2.2.tar.gz?r=&ts=1481630635&use_mirror=netix
#wget "http://downloads.sourceforge.net/project/soci/soci/soci-3.2.2/soci-3.2.2.tar.gz"
if $is_dev
then
      echo Building a debug image
      touch /root/debug_image
      cd /sdcard/upgrade/
fi
wget "https://datapacket.dl.sourceforge.net/project/soci/soci/soci-3.2.2/soci-3.2.2.tar.gz" || wget "http://netix.dl.sourceforge.net/project/soci/soci/soci-3.2.2/soci-3.2.2.tar.gz"
tar xpvzf soci-3.2.2.tar.gz
dpkg --configure -a
cd soci-3.2.2
cmake -DCMAKE_BUILD_TYPE=Release -DSOCI_STATIC=OFF -DSOCI_TESTS=OFF -DWITH_SQLITE3=OFF -DSOCI_EMPTY=OFF -DWITH_MYSQL=ON -G "Unix Makefiles" || exit 1
make || exit 1
make install || exit 1
cd ..

dpkg --configure -a

if $is_dev
then
      echo Building a debug image
else
     rm -rf soci-3.2.2*
fi

df -h
