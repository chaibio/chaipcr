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
    source /usr/local/rvm/scripts/rvm
    rvm install 2.2.9
    rvm --default use 2.2.9
  INSTALL
  not_if (RUBY_VERSION == '2.2.9')
end
