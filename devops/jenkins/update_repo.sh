#!/bin/bash

cp --parents  /var/lib/jenkins/jobs/*/config.xml -r .
cp -r var/lib/jenkins/jobs .
rm -r var

find . -name *.xml -type f -exec sed -i "s/192.168.1.201/10.0.1.20/g"  {} \;
find . -name *.xml -type f -exec sed -i "s/192.168.1.200/10.0.1.20/g"  {} \;
find . -name *.xml -type f -exec sed -i "s/192.168.1.33/10.0.100.240/g"  {} \;
find . -name *.xml -type f -exec sed -i "s/192.168.1.44/10.0.100.240/g"  {} \;
find . -name *.xml -type f -exec sed -i "s/192.168.1.55/10.0.100.240/g"  {} \;
find . -name *.xml -type f -exec sed -i "s/192.168.1.112/10.0.100.240/g"  {} \;
find . -name *.xml -type f -exec sed -i "s/192.168.1.88/10.0.100.240/g"  {} \;
find . -name *.xml -type f -exec sed -i "s/192.168.1.99/10.0.100.240/g"  {} \;

sync

git diff .
