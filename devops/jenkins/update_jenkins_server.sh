#!/bin/bash

/etc/init.d/jenkins stop
if [ -e /var/lib/jenkins/backup ]
then
    	echo backup folder exits
else
	echo creating backup folder
	mkdir /var/lib/jenkins/backup/
fi

tar zfvc /var/lib/jenkins/backup/update_from_repo_$(date  +"%Y_%m_%d_%I_%M").tgz /var/lib/jenkins/jobs
#rm -r /var/lib/jenkins/jobs
cp -r . /var/lib/jenkins/
chmod 777 /var/lib/jenkins/jobs
chmod 777 /var/lib/jenkins/jobs/*
chmod 777 /var/lib/jenkins/jobs/*/config.xml

/etc/init.d/jenkins start

