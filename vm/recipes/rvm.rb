#
# Cookbook:: vm
# Recipe:: rvm.rb
#
# install rvm
#
bash 'rvm' do
  user 'vagrant'
  cwd '/tmp'
  code <<~RVM
    gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
    curl -sSL https://get.rvm.io -o rvm.sh
    cat rvm.sh | bash -s stable --rails
    source ~/.rvm/scripts/rvm
    echo 'export rvm_max_time_flag=20' >> ~/.rvmrc
    echo '[[ -s $HOME/.rvm/scripts/rvm ]] && source $HOME/.rvm/scripts/rvm' >> ~/.bashrc
    touch /tmp/.vagrant-rvm
  RVM
  not_if { ::File.exist?('/tmp/.vagrant-rvm') }
end
