#!/bin/bash

/usr/local/bin/bundle exec /usr/local/bin/rake db:migrate
/usr/local/bin/bundle exec /usr/local/bin/rake db:seed_fu
ruby scripts/upgrade.rb