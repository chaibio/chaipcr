#
# Cookbook:: vm
# Test:: julia_test
#
# Author: Tom Price
# Date: Dec 2018
#
# Inspec tests for recipe vm::julia
#
# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/
#
describe bash('/usr/local/bin/julia -v') do
  its('stdout') { should match /0.6.2/ }
  its('stderr') { should eq '' }
  its('exit_status') { should eq 0 }
end

describe bash("julia --compile=min -e 'println(Pkg.installed(\"Ipopt\"))'") do
  its('stdout') { should match /0.2.6/ }
  its('stderr') { should eq '' }
  its('exit_status') { should eq 0 }
end

