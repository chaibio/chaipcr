#!/bin/bash

chown -R mysql /data/mysql
chgrp -R mysql /data/mysql
systemctl start realtime.service
sleep 3

/usr/local/bin/bundle exec /usr/local/bin/rake db:migrate
/usr/local/bin/bundle exec /usr/local/bin/rake db:seed_fu
ruby scripts/upgrade.rb