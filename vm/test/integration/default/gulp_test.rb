#
# Cookbook:: vm
# Test:: gulp_test
#
# Author: Tom Price
# Date: Dec 2018
#
# Inspec tests for recipe vm::gulp
#
# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/
#
describe npm('gulp') do
  it { should be_installed }
  its('version') { should eq '3.9.1' }
end