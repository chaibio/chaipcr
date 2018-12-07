#
# Cookbook:: vm
# Test:: clone_test
#
# Author: Tom Price
# Date: Dec 2018
#
# Inspec tests for recipe vm::clone
#
# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/
#
describe package('git') do
  it { should be_installed }
end
