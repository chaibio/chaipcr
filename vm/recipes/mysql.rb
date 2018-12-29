#
# Cookbook:: vm
# Recipe:: mysql.rb
#
# install and start MySql server and client
#
package %w(
  mysql-server
  mysql-client
  libmysqlclient-dev
  libmysqld-dev
)
# idempotent

bash 'mysql' do
  user 'vagrant'
  code <<~MYSQL
    sudo mysql -u root << SQLSCRIPT
      ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY "";
      CREATE DATABASE chaipcr;
      QUIT
    SQLSCRIPT
    cat << BASHRC >> ~/.bashrc
      if [ -L /tmp/mysql.sock ] && [ -e /tmp/mysql.sock ] ; then
        echo "Symbolic link for /tmp/mysql.sock created, Good to go with DB testing"
      else
        ln -s /var/run/mysqld/mysqld.sock /tmp/mysql.sock
      fi
    BASHRC
    touch /tmp/.vagrant-mysql
  MYSQL
  not_if { ::File.exist?('/tmp/.vagrant-mysql') }
end

#mysql_service 'server' do
#  port '3306'
#  version '5.7'
#  initial_root_password ''
#  socket '/var/run/mysqld/mysqld.sock'
#  action [:create, :start]
#end

#mysql_client 'default' do
#  action :create
#end


