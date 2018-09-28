#!/bin/bash

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

rsync --delete --rsh="sshpass $remote_password_param ssh -oStrictHostKeyChecking=no -l root" -a ./web "$1:/root/chaipcr/"
rsync --delete --rsh="sshpass $remote_password_param ssh -oStrictHostKeyChecking=no -l root" -a ./browser "$1:/root/chaipcr/"
rsync --delete --rsh="sshpass $remote_password_param ssh -oStrictHostKeyChecking=no -l root" -a ./bioinformatics "$1:/root/chaipcr/"
rsync --delete --rsh="sshpass $remote_password_param ssh -oStrictHostKeyChecking=no -l root" -a ./device/configuration.json "$1:/root/chaipcr/deploy/"
rsync --delete --rsh="sshpass $remote_password_param ssh -oStrictHostKeyChecking=no -l root" -a ./device/configuration.json "$1:/root/"
rsync --delete --rsh="sshpass $remote_password_param ssh -oStrictHostKeyChecking=no -l root" -a ./devops/factory_settings_sdcard/scripts/replace_uEnv.txt.sh "$1:/root/chaipcr/deploy/"
rsync --delete --rsh="sshpass $remote_password_param ssh -oStrictHostKeyChecking=no -l root" -a ./devops/device "$1:/root/chaipcr/deploy/"
rsync --delete --rsh="sshpass $remote_password_param ssh -oStrictHostKeyChecking=no -l root" -a ./modules "$1:/root/chaipcr/"
rsync --delete --rsh="sshpass $remote_password_param ssh -oStrictHostKeyChecking=no -l root" -a ./realtime/overlay "$1:/root/chaipcr/deploy/"
