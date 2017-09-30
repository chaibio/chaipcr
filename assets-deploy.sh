#!/bin/bash

if [ -z $(which sshpass) ]
then
	echo installing sshpass
	sudo apt-get install -y sshpass
fi

if [ ! -n "$remote_password" ]
then
  echo "Enter remote password: "
  read remote_password

  if [ -z $remote_password ]
  then
    echo "Password can't be empty!"
    exit
  fi
fi

rm -rf ./web/log
rsync --delete --rsh="sshpass -p $remote_password ssh -oStrictHostKeyChecking=no -l root" -a ./web/public "$1:/root/chaipcr/web"
rsync --delete --rsh="sshpass -p $remote_password ssh -oStrictHostKeyChecking=no -l root" -a ./ng2/dist "$1:/root/chaipcr/ng2"
