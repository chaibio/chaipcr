#
# Cookbook:: vm
# Test:: ruby_test
#
# Author: Tom Price
# Date: Dec 2018
#
# Inspec tests for recipe vm::ruby
#
# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/
#
describe bash(
  'source /home/vagrant/.rvm/scripts/rvm;
  ruby -e "puts RUBY_VERSION"'
  ) do
  its('stdout') { should match /2.2.9/ }
  its('stderr') { should eq '' }
  its('exit_status') { should eq 0 }
end
