#
# Cookbook:: vm
# Recipe:: rails_db.rb
#
# set up & migrate db
#
bash 'db' do
  cwd '/home/vagrant/chaipcr/web'
  code <<~DB
    cp -p config/database-sample.yml config/database.yml
  DB
  not_if { ::File.exist?('/home/vagrant/chaipcr/web/config/database.yml') }
end

bash 'rails' do
  user 'vagrant'
  cwd '/home/vagrant/chaipcr/web'
  code <<~RAILS
    sudo chown -R vagrant:vagrant .
    if [ ! -d log ]; then
      mkdir log
    fi
    if [ ! -e log/development.log ]; then
      touch log/development.log
    fi
    source /usr/local/rvm/scripts/rvm
    rvm --default use 2.2.9
    ./bin/rake db:setup   RAILS_ENV=development
    ./bin/rake db:seed_fu RAILS_ENV=development
    ./bin/rake db:migrate RAILS_ENV=development
  RAILS
  only_if (RUBY_VERSION == '2.2.9' && ::File.exist?('/home/vagrant/chaipcr/web/config/database.yml'))
end
