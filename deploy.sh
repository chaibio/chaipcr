#!/bin/bash

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
rsync --delete --rsh="sshpass -p $remote_password ssh -l root" -a ./devops/device "$1:/root/chaipcr/deploy/"
rsync --delete --rsh="sshpass -p $remote_password ssh -l root" -a ./modules "$1:/root/chaipcr/"
rsync --delete --rsh="sshpass -p $remote_password ssh -l root" -a ./realtime/overlay "$1:/root/chaipcr/deploy/"
