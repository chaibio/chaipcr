#!/bin/bash

echo Setup a Jenkins Server:
wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
sh -c 'echo deb http://pkg.jenkins-ci.org/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
apt update
apt install openjdk-8-jdk-headless openjdk-8-jre-headless curl
apt install jenkins git nginx
ufw app list

mkdir -p /usr/share/nginx/html/download/support_files/
chmod 777 /usr/share/nginx/html/download/*
chmod 777 /usr/share/nginx/html/download
echo donwload support files to /usr/share/nginx/html/download/support_files/*
read -p "Press any key to resume ..."

chmod 777 /usr/share/nginx/html/download/support_files/*

echo install the mandatory plugins
echo 	MultiJob
echo 	SSH
echo 	Naginator
echo 	SSH Build
echo 	Summary Display
echo 	Timestamper
echo 	Build Timeout
echo 	Git client plugin
 
read -p "Press any key to resume ..."
./update_jenkins_server.sh

