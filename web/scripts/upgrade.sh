#!/bin/bash
ruby scripts/upgrade.rb
/usr/local/bin/bundle exec /usr/local/bin/rake db:migrate
/usr/local/bin/bundle exec /usr/local/bin/rake db:seed_fu

# boxing transactions queue. This should work on the database upgrade case.
MYSQL_USER=root
MYSQL_CONN="-u${MYSQL_USER} --password="
SQL="SET GLOBAL innodb_fast_shutdown = 0"
mysql ${MYSQL_CONN} -ANe"${SQL}"
mysqladmin ${MYSQL_CONN} shutdown
if [ -e /data/mysql ]
then
        cd /data/mysql/
else
        cd /var/lib/mysql/
fi
rm -f ib_logfile*
echo "[mysqld]">/etc/mysql/conf.d/chaibio.cnf
echo "innodb_log_file_size = 5M">>/etc/mysql/conf.d/chaibio.cnf
service mysql start

echo "Done upgrading DB and shrinking transactions queue"
