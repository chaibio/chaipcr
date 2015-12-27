#!/bin/bash

echo "Enter remote password: "
read remote_password

rsync --rsh="sshpass -p $remote_password ssh -l root" -a ./web "$1:/root/chaipcr/"
rsync --rsh="sshpass -p $remote_password ssh -l root" -a ./device/configuration.json "$1:/root/chaipcr/deploy/"
rsync --rsh="sshpass -p $remote_password ssh -l root" -a ./devops/factory_settings_sdcard/replace_uEnv.txt.sh "$1:/root/chaipcr/deploy/"
rsync --rsh="sshpass -p $remote_password ssh -l root" -a ./devops/device "$1:/root/chaipcr/deploy/"
