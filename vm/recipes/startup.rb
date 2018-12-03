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
    touch /tmp/.bashrc_edited
  STARTUP
  not_if { ::File.exist?('/tmp/.bashrc_edited') }
end
