#
# Cookbook:: vm
# Test:: gem_test
#
# Author: Tom Price
# Date: Dec 2018
#
# Inspec tests for recipe vm::gem
#
# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/
#
describe gem('rake', '/home/vagrant/.rvm/gems/ruby-2.2.9@global/gems') do
  it { should be_installed }
  its('version') { should eq '10.4.2' }
end

describe gem('bundler', '/home/vagrant/.rvm/gems/ruby-2.2.9@global/gems') do
  it { should be_installed }
  its('version') { should cmp >= '1.16' }
end