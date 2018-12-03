#
# Cookbook:: vm
# Test:: rails_test
#
# Author: Tom Price
# Date: Dec 2018
#
# Inspec tests for recipe vm::rails
#
# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/
#
describe bash(
  '. ~/.rvm/scripts/rvm;
  rvm use 2.2.9;
  cd ~/chaipcr/web;
  bundle install;
  ./bin/rake db:migrate:status RAILS_ENV=development|grep up|wc -l'
  ) do
  its('stdout') { should eq '55' }
  its('stderr') { should eq '' }
  its('exit_status') { should eq 0 }
end
