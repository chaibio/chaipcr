#!/bin/bash

if [ -z $1 ]
then
	echo Usage: ./deploy.sh deviceip
	echo ex: ./deploy.sh 10.0.100.242
	exit 1	
fi

if [ -z $(which sshpass) ]
then
	echo installing sshpass
	sudo apt-get install -y -q sshpass
fi

remote_password_param=

if [ ! -n "$remote_password" ]
then
 echo "Enter remote password: "
 read remote_password

 if [ -z $remote_password ]
 then
	remote_password_param=
 else
	remote_password_param="-p $remote_password "
 fi
fi

rm -rf ./web/log
ssh-keygen -f "/root/.ssh/known_hosts" -R $1

rsync --delete --rsh="sshpass $remote_password_param ssh -oStrictHostKeyChecking=no -l root" -a ./ "$1:/root/chaipcr/bioinformatics/" || (echo error copying julia files to device && exit 1)

exit 1