#
# Cookbook:: vm
# Test:: default_test
#
# Author: Tom Price
# Date: Dec 2018
#
# Inspec tests
#
# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/
#
describe user('vagrant') do
  it { should exist }
end

describe package('curl') do
  it { should be_installed }
end

describe package('nodejs') do
  it { should be_installed }
  its('version') { should cmp >= '6.0.0' }
end

describe package('unzip') do
  it { should be_installed }
end
