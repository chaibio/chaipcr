# # encoding: utf-8

# Inspec tests for recipe vm::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe user('vagrant') do
  it { should exist }
end

describe port(3306) do
  it { should be_listening }
end

describe 'mysql::server' do
  service(node['mysql']['service_name']).must_be_running
end