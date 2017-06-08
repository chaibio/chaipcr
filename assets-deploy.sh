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
rsync --delete --rsh="sshpass -p $remote_password ssh -oStrictHostKeyChecking=no -l root" -a ./web/public/javascripts "$1:/root/chaipcr/web/public"
rsync --delete --rsh="sshpass -p $remote_password ssh -oStrictHostKeyChecking=no -l root" -a ./web/public/stylesheets "$1:/root/chaipcr/web/public"
rsync --delete --rsh="sshpass -p $remote_password ssh -oStrictHostKeyChecking=no -l root" -a ./web/public/fonts "$1:/root/chaipcr/web/public"
rsync --delete --rsh="sshpass -p $remote_password ssh -oStrictHostKeyChecking=no -l root" -a ./web/public/images "$1:/root/chaipcr/web/public"
rsync --delete --rsh="sshpass -p $remote_password ssh -oStrictHostKeyChecking=no -l root" -a ./web/app/views "$1:/root/chaipcr/web/app"