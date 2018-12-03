#
# Cookbook:: vm
# Recipe:: clone_development.rb
#
# clone chaipcr repo, development branch
#
bash 'clone_development' do
  user 'vagrant'
  code <<~CLONE
    cd ~
    git clone https://github.com/chaibio/chaipcr.git
    cd chaipcr
    git init
    git checkout development
    touch /tmp/.vagrant-clone
  CLONE
  not_if { ::File.exist?('/tmp/.vagrant-clone') }
end
