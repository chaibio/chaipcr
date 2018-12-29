#
# Cookbook:: vm
# Recipe:: clone_master.rb
#
# clone chaipcr repo, master branch
#
bash 'clone_master' do
  user 'vagrant'
  code <<~CLONE
    cd ~
    git clone https://github.com/chaibio/chaipcr.git
    cd chaipcr
    git init
    git checkout master
    touch /tmp/.vagrant-clone
  CLONE
  not_if { ::File.exist?('/tmp/.vagrant-clone') }
end
