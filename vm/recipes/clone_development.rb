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
  CLONE
  not_if { ::File.exist?('/home/vagrant/chaipcr/.git') }
end
