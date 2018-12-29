#
# Cookbook:: vm
# Recipe:: startup.rb
#
# run startup script
#
bash 'bashrc' do
  user 'vagrant'
  code <<~STARTUP
    source ~/.bashrc
    touch /tmp/.vagrant-startup
  STARTUP
  not_if { ::File.exist?('/tmp/.vagrant-startup') }
end
