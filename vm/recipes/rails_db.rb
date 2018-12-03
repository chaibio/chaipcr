#
# Cookbook:: vm
# Recipe:: rails_db.rb
#
# set up & migrate db
#
bash 'db' do
  user 'vagrant'
  code <<~RAILS
    cd ~/chaipcr/web
    cp -p config/database-sample.yml config/database.yml
    sudo chown -R vagrant:vagrant .
    if [ ! -d log ]; then
      mkdir log
    fi
    if [ ! -e log/development.log ]; then
      touch log/development.log
    fi
    source ~/.rvm/scripts/rvm
    rvm --default use 2.2.9
    ./bin/rake db:setup   RAILS_ENV=development
    ./bin/rake db:seed_fu RAILS_ENV=development
    ./bin/rake db:migrate RAILS_ENV=development
    touch /tmp/.vagrant-rails
  RAILS
  not_if { ::File.exist?('/tmp/.vagrant-rails') }
end
