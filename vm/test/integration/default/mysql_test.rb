#
# Cookbook:: vm
# Test:: mysql_test
#
# Author: Tom Price
# Date: Dec 2018
#
# Inspec tests for recipe vm::mysql
#
# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/
#
describe package('mysql-server') do
  it { should be_installed }
end

describe package('mysql-client') do
  it { should be_installed }
end

describe mysql_conf('/etc/mysql/mysql.conf.d/mysqld.cnf').params('mysqld') do
  its('user') { should eq 'mysql' }
  its('port') { should eq '3306' }
  its('socket') { should eq '/var/run/mysqld/mysqld.sock' }
  its('bind-address') { should eq '127.0.0.1' }
end

describe port(3306) do
  it { should be_listening }
  its('protocols') { should include('tcp') }
end

describe command("sudo mysql -h localhost -u root -s -e 'show databases;'") do
  its('stdout') { should match(/mysql/) }
end