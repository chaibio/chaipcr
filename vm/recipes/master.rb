#
# Cookbook:: vm
# Recipe:: master.rb
#
# set up chaipcr development environment on VM
#
include_recipe 'vm::clone_master'
include_recipe 'vm::device'
include_recipe 'vm::mysql'
include_recipe 'vm::julia'
include_recipe 'vm::rvm'
include_recipe 'vm::ruby'
include_recipe 'vm::gems'
include_recipe 'vm::gulp'
include_recipe 'vm::rails_db'
include_recipe 'vm::startup'

apt_update 'daily' do
  frequency 86_400
  action :periodic
end
