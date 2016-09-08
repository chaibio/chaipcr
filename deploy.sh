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
rsync --delete --rsh="sshpass -p $remote_password ssh -l root" -a ./web "$1:/root/chaipcr/"
rsync --delete --rsh="sshpass -p $remote_password ssh -l root" -a ./browser "$1:/root/chaipcr/"
rsync --delete --rsh="sshpass -p $remote_password ssh -l root" -a ./bioinformatics "$1:/root/chaipcr/"
rsync --delete --rsh="sshpass -p $remote_password ssh -l root" -a ./device/configuration.json "$1:/root/chaipcr/deploy/"
rsync --delete --rsh="sshpass -p $remote_password ssh -l root" -a ./devops/factory_settings_sdcard/scripts/replace_uEnv.txt.sh "$1:/root/chaipcr/deploy/"
rsync --delete --rsh="sshpass -p $remote_password ssh -l root" -a ./devops/factory_settings_sdcard/MLO "$1:/boot/uboot/"
rsync --delete --rsh="sshpass -p $remote_password ssh -l root" -a ./devops/factory_settings_sdcard/u-boot.img "$1:/boot/uboot/"
rsync --delete --rsh="sshpass -p $remote_password ssh -l root" -a ./devops/device "$1:/root/chaipcr/deploy/"
rsync --delete --rsh="sshpass -p $remote_password ssh -l root" -a ./modules "$1:/root/chaipcr/"
rsync --delete --rsh="sshpass -p $remote_password ssh -l root" -a ./realtime/overlay "$1:/root/chaipcr/deploy/"
