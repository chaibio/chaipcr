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

gulp deploy
cd touchapp
npm run build
cd ..

rsync --delete --rsh="sshpass $remote_password_param ssh -oStrictHostKeyChecking=no -l root" -a ./web "$1:/root/chaipcr/"
rsync --delete --rsh="sshpass $remote_password_param ssh -oStrictHostKeyChecking=no -l root" -a ./browser "$1:/root/chaipcr/"
rsync --delete --rsh="sshpass $remote_password_param ssh -oStrictHostKeyChecking=no -l root" -a ./device/configuration.json "$1:/root/chaipcr/deploy/"
rsync --delete --rsh="sshpass $remote_password_param ssh -oStrictHostKeyChecking=no -l root" -a ./device/configuration.json "$1:/root/"
rsync --delete --rsh="sshpass $remote_password_param ssh -oStrictHostKeyChecking=no -l root" -a ./touchapp/touchapp.nginx.conf "$1:/etc/nginx/sites-enabled/"
rsync --delete --rsh="sshpass $remote_password_param ssh -oStrictHostKeyChecking=no -l root" -a ./touchapp/dist "$1:/root/chaipcr/touchapp"

sshpass $remote_password_param ssh -t "root@$1" "cd ~/chaipcr/web; bundle"
sshpass $remote_password_param ssh -t "root@$1" "cd ~/chaipcr/web; RAILS_ENV=production bundle exec rake db:migrate"
sshpass $remote_password_param ssh -t "root@$1" "cd ~/chaipcr/web; RAILS_ENV=production bundle exec rake db:seed_fu"
echo "Deploy complete, restarting $1"
sshpass $remote_password_param ssh -t "root@$1" "reboot"
