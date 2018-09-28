#!/bin/bash
ruby scripts/upgrade.rb
/usr/local/bin/bundle exec /usr/local/bin/rake db:migrate
/usr/local/bin/bundle exec /usr/local/bin/rake db:seed_fu
