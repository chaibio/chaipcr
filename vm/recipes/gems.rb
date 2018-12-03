#
# Cookbook:: vm
# Recipe:: gems.rb
#
# install gems from Gemfile
#
bash 'gems' do
  user 'vagrant'
  code <<~GEMS
	cd ~/chaipcr/web
    source /usr/local/rvm/scripts/rvm
    rvm --default use 2.2.9
    bundle install
  GEMS
  only_if (RUBY_VERSION == '2.2.9' && not(system('bundle check')))
end
