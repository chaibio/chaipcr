#
# Cookbook:: vm
# Recipe:: ruby.rb
#
# install Ruby 2.2.9 and gems from Gemfile
#
bash 'install_ruby' do
  user 'vagrant'
  code <<~INSTALL
	cd ~/chaipcr/web
    source ~/.rvm/scripts/rvm
    rvm install 2.2.9
    rvm --default use 2.2.9
    touch /tmp/.vagrant-ruby
  INSTALL
  not_if { ::File.exist?('/tmp/.vagrant-ruby') }
end
