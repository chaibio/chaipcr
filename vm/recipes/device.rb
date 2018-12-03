#
# Cookbook:: vm
# Recipe:: device.rb
#
# create /perm directory for device settings
# copy single_channel_device.json or dual_channel_device.json
# as appropriate for the data sourced in the MySql DB
#
bash 'device' do
  user 'vagrant'
  code <<~DEVICE
    sudo mkdir /perm
    sudo cp -p ~/chaipcr/device/device.json /perm/device.json
    ##sudo cp -p ~/chaipcr/device/single_channel_device.json /perm/device.json
    ##sudo cp -p ~/chaipcr/device/dual_channel_device.json /perm/device.json
    echo 'export DEVICE_FILE_PATH=/perm/device.json' >> ~/.bashrc
  DEVICE
  not_if { ::File.exist?('perm/device.json') }
end
